import { relative, resolve, sep } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { splitCommand } from './matcher.ts';

interface ExecResult {
	stdout: string;
	stderr: string;
	code: number;
	killed: boolean;
}

export interface GitProbe {
	findRepositoryRoot(cwd: string): Promise<string | undefined>;
	isTracked(
		repositoryRoot: string,
		cwd: string,
		path: string,
	): Promise<boolean>;
}

export type GitTrackedRmAction =
	| { action: 'unchanged' }
	| { action: 'rewrite'; command: string }
	| { action: 'block'; reason: string };

interface Token {
	value: string;
	literal: boolean;
}

interface TokenizeResult {
	tokens: Token[];
	hasControlOrRedirect: boolean;
	hasUnsupportedSyntax: boolean;
}

interface RmInvocation {
	pathArgs: Token[];
	hasUnsupportedSyntax: boolean;
	hasUnsupportedOption: boolean;
}

const UNCHANGED: GitTrackedRmAction = { action: 'unchanged' };

export function createGitProbe(pi: Pick<ExtensionAPI, 'exec'>): GitProbe {
	return {
		async findRepositoryRoot(cwd: string): Promise<string | undefined> {
			const result = await safeExec(
				pi,
				'git',
				['rev-parse', '--show-toplevel'],
				{ cwd },
			);
			if (!result || result.code !== 0) return undefined;
			const root = result.stdout.trim();
			return root ? root : undefined;
		},

		async isTracked(
			repositoryRoot: string,
			cwd: string,
			path: string,
		): Promise<boolean> {
			const relativePath = pathRelativeToRepository(repositoryRoot, cwd, path);
			if (!relativePath) return false;
			const result = await safeExec(
				pi,
				'git',
				['ls-files', '--error-unmatch', '--', relativePath],
				{ cwd: repositoryRoot },
			);
			return result?.code === 0;
		},
	};
}

async function safeExec(
	pi: Pick<ExtensionAPI, 'exec'>,
	command: string,
	args: string[],
	options: { cwd: string },
): Promise<ExecResult | undefined> {
	try {
		return await pi.exec(command, args, { ...options, timeout: 3000 });
	} catch {
		return undefined;
	}
}

function pathRelativeToRepository(
	repositoryRoot: string,
	cwd: string,
	path: string,
): string | undefined {
	const absoluteRoot = resolve(repositoryRoot);
	const absolutePath = resolve(cwd, path);
	const relativePath = relative(absoluteRoot, absolutePath);
	if (relativePath === '') return undefined;
	if (relativePath === '..' || relativePath.startsWith(`..${sep}`))
		return undefined;
	return relativePath;
}

export async function planGitTrackedRm(
	command: string,
	cwd: string,
	probe: GitProbe,
): Promise<GitTrackedRmAction> {
	const repositoryRoot = await probe.findRepositoryRoot(cwd);
	if (!repositoryRoot) return UNCHANGED;

	const simple = parseDirectRm(command);
	if (simple?.kind === 'direct')
		return planDirectRm(command, repositoryRoot, cwd, simple.invocation, probe);
	if (simple?.kind === 'not-rm') return UNCHANGED;

	for (const segment of splitCommand(command)) {
		const segmentParse = parsePotentialRm(segment);
		if (segmentParse?.kind !== 'direct') continue;
		const trackedPaths = await trackedLiteralPaths(
			repositoryRoot,
			cwd,
			segmentParse.invocation.pathArgs,
			probe,
		);
		if (trackedPaths.length > 0) return blockTrackedRm(trackedPaths);
	}

	return UNCHANGED;
}

async function planDirectRm(
	originalCommand: string,
	repositoryRoot: string,
	cwd: string,
	invocation: RmInvocation,
	probe: GitProbe,
): Promise<GitTrackedRmAction> {
	if (invocation.pathArgs.length === 0) return UNCHANGED;

	const literalPaths = invocation.pathArgs
		.filter((arg) => arg.literal)
		.map((arg) => arg.value);
	const trackedPaths = await trackedLiteralPaths(
		repositoryRoot,
		cwd,
		invocation.pathArgs,
		probe,
	);
	if (trackedPaths.length === 0) return UNCHANGED;

	const allPathsAreLiteral = literalPaths.length === invocation.pathArgs.length;
	const allPathsAreTracked = trackedPaths.length === invocation.pathArgs.length;
	if (
		!allPathsAreLiteral ||
		!allPathsAreTracked ||
		invocation.hasUnsupportedSyntax ||
		invocation.hasUnsupportedOption
	) {
		return blockTrackedRm(trackedPaths);
	}

	return {
		action: 'rewrite',
		command: `git rm -- ${invocation.pathArgs.map((arg) => shellQuote(arg.value)).join(' ')}`,
	};
}

async function trackedLiteralPaths(
	repositoryRoot: string,
	cwd: string,
	pathArgs: Token[],
	probe: GitProbe,
): Promise<string[]> {
	const trackedPaths: string[] = [];
	for (const arg of pathArgs) {
		if (!arg.literal) continue;
		if (await probe.isTracked(repositoryRoot, cwd, arg.value))
			trackedPaths.push(arg.value);
	}
	return trackedPaths;
}

function blockTrackedRm(paths: string[]): GitTrackedRmAction {
	const detail = paths.length > 0 ? `: ${paths.join(', ')}` : '';
	return {
		action: 'block',
		reason: `Blocked because this rm would remove Git-tracked file(s)${detail}. Use git rm -- <path> instead.`,
	};
}

function parseDirectRm(
	command: string,
):
	| { kind: 'direct'; invocation: RmInvocation }
	| { kind: 'not-rm' }
	| undefined {
	const parsed = tokenize(command);
	if (parsed.hasControlOrRedirect) return undefined;
	return parseRmTokens(parsed);
}

function parsePotentialRm(
	command: string,
):
	| { kind: 'direct'; invocation: RmInvocation }
	| { kind: 'not-rm' }
	| undefined {
	return parseRmTokens(tokenize(command));
}

function parseRmTokens(
	parsed: TokenizeResult,
):
	| { kind: 'direct'; invocation: RmInvocation }
	| { kind: 'not-rm' }
	| undefined {
	const [program, ...args] = parsed.tokens;
	if (!program) return { kind: 'not-rm' };
	if (program.value !== 'rm' && program.value !== '/bin/rm')
		return { kind: 'not-rm' };

	const pathArgs: Token[] = [];
	let hasUnsupportedOption = false;
	let afterOptions = false;
	for (const arg of args) {
		if (!afterOptions && arg.value === '--') {
			afterOptions = true;
			continue;
		}
		if (!afterOptions && arg.value.startsWith('-')) {
			hasUnsupportedOption = true;
			continue;
		}
		pathArgs.push(arg);
	}

	return {
		kind: 'direct',
		invocation: {
			pathArgs,
			hasUnsupportedSyntax: parsed.hasUnsupportedSyntax,
			hasUnsupportedOption,
		},
	};
}

function tokenize(command: string): TokenizeResult {
	const tokens: Token[] = [];
	let current = '';
	let currentLiteral = true;
	let quote: 'single' | 'double' | undefined;
	let hasControlOrRedirect = false;
	let hasUnsupportedSyntax = false;

	const push = () => {
		if (!current) return;
		tokens.push({ value: current, literal: currentLiteral });
		current = '';
		currentLiteral = true;
	};

	for (let i = 0; i < command.length; i++) {
		const ch = command[i];

		if (quote === 'single') {
			if (ch === "'") quote = undefined;
			else current += ch;
			continue;
		}

		if (quote === 'double') {
			if (ch === '"') {
				quote = undefined;
				continue;
			}
			if (ch === '$' || ch === '`' || ch === '\\') {
				hasUnsupportedSyntax = true;
				currentLiteral = false;
			}
			current += ch;
			continue;
		}

		if (/\s/.test(ch)) {
			push();
			continue;
		}
		if (ch === "'") {
			quote = 'single';
			continue;
		}
		if (ch === '"') {
			quote = 'double';
			continue;
		}
		if (
			ch === '|' ||
			ch === '&' ||
			ch === ';' ||
			ch === '\n' ||
			ch === '<' ||
			ch === '>'
		) {
			hasControlOrRedirect = true;
			hasUnsupportedSyntax = true;
			push();
			continue;
		}
		if (
			ch === '$' ||
			ch === '`' ||
			ch === '\\' ||
			ch === '*' ||
			ch === '?' ||
			ch === '[' ||
			ch === ']' ||
			ch === '{' ||
			ch === '}' ||
			ch === '(' ||
			ch === ')'
		) {
			hasUnsupportedSyntax = true;
			currentLiteral = false;
		}
		current += ch;
	}
	push();
	if (quote) hasUnsupportedSyntax = true;

	return { tokens, hasControlOrRedirect, hasUnsupportedSyntax };
}

function shellQuote(value: string): string {
	if (/^[A-Za-z0-9_./:@%+=,-]+$/.test(value)) return value;
	return `'${value.replaceAll("'", "'\\''")}'`;
}
