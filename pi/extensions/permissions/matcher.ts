/**
 * Risk-based matching logic: given the gated tool and its subject (bash command
 * or file path), decide whether it is safe, should prompt, or must be blocked.
 */
import { isAbsolute, resolve } from "node:path";
import { globMatches } from "./glob.ts";

/** pi tool name -> label used in permission entries. */
export const TOOL_LABELS: Record<string, string> = {
	bash: "Bash",
	read: "Read",
	write: "Write",
	edit: "Edit",
};

export type Decision = "allow" | "deny" | "prompt";

export interface DecisionDetails {
	decision: Decision;
	segments: string[];
	deniedSegments: string[];
	unmatchedSegments: string[];
	riskyRedirectTargets: string[];
	promptSegments: string[];
	reasons: string[];
}

/** Parse `Bash(git *)` -> { label: "Bash", glob: "git *" }. */
function parseEntry(entry: string): { label: string; glob: string } | undefined {
	const m = /^(\w+)\((.*)\)$/s.exec(entry.trim());
	if (!m) return undefined;
	return { label: m[1], glob: m[2] };
}

/** Globs from `entries` that target the given tool label. */
function globsFor(entries: string[], label: string): string[] {
	const out: string[] = [];
	for (const entry of entries) {
		const parsed = parseEntry(entry);
		if (parsed && parsed.label.toLowerCase() === label.toLowerCase()) out.push(parsed.glob);
	}
	return out;
}

/** True when a shell fragment may execute another command while being parsed. */
function hasCommandSubstitution(command: string): boolean {
	return command.includes("$(`") || command.includes("$(") || command.includes("`");
}

/** Normalise shell syntax down to commands that actually run. */
function normalizeShellSegment(segment: string): string | undefined {
	let s = segment.trim();
	if (!s) return undefined;

	if (/^(?:do|done|then|fi|esac|\{|\})$/.test(s)) return undefined;

	s = s.replace(/^(?:do|then|else)\s+/, "").trim();
	if (!s) return undefined;

	s = s.replace(/^(?:if|while|until)\s+/, "").trim();
	if (!s) return undefined;

	if (/^(?:for|select)\s+\w+\s+in\b/.test(s) && !hasCommandSubstitution(s)) return undefined;

	return s;
}

/**
 * Split a bash command into independently-executed segments on shell control
 * operators: && || ; | & and newlines. Single and double quotes are respected
 * so separators inside strings do not over-split.
 */
export function splitCommand(command: string): string[] {
	const raw: string[] = [];
	let current = "";
	let quote: "'" | '"' | undefined;
	let escaped = false;

	for (let i = 0; i < command.length; i++) {
		const ch = command[i];
		const next = command[i + 1];

		if (escaped) {
			current += ch;
			escaped = false;
			continue;
		}
		if (ch === "\\") {
			current += ch;
			escaped = true;
			continue;
		}
		if (quote) {
			current += ch;
			if (ch === quote) quote = undefined;
			continue;
		}
		if (ch === "'" || ch === '"') {
			current += ch;
			quote = ch;
			continue;
		}

		if (ch === "\n" || ch === ";" || ch === "|" || ch === "&") {
			raw.push(current);
			current = "";
			if ((ch === "|" && next === "|") || (ch === "&" && next === "&")) i++;
			continue;
		}

		current += ch;
	}
	raw.push(current);

	return raw.map(normalizeShellSegment).filter((s): s is string => s !== undefined);
}

const BENIGN_REDIRECT_TARGETS = new Set(["/dev/null", "/dev/stdout", "/dev/stderr"]);

function isTmpPath(target: string): boolean {
	return target === "/tmp" || target.startsWith("/tmp/") || target.startsWith("/tmp");
}

function isBenignTarget(target: string): boolean {
	return BENIGN_REDIRECT_TARGETS.has(target) || target.startsWith("/dev/fd/") || isTmpPath(target);
}

function stripRedirections(command: string): string {
	const redir =
		/(?:[0-9]+|&)?(?:>>?|<<?<?)\s*(?:&[0-9-]+|"[^"]*"|'[^']*'|[^\s|;&<>()]+)?/g;
	return command.replace(redir, " ");
}

function unquote(token: string): string {
	if (
		(token.startsWith('"') && token.endsWith('"')) ||
		(token.startsWith("'") && token.endsWith("'"))
	) {
		return token.slice(1, -1);
	}
	return token;
}

function shellTokens(command: string): string[] {
	const tokens: string[] = [];
	let current = "";
	let quote: "'" | '"' | undefined;
	let escaped = false;

	for (let i = 0; i < command.length; i++) {
		const ch = command[i];
		if (escaped) {
			current += ch;
			escaped = false;
			continue;
		}
		if (ch === "\\") {
			escaped = true;
			continue;
		}
		if (quote) {
			current += ch;
			if (ch === quote) quote = undefined;
			continue;
		}
		if (ch === "'" || ch === '"') {
			current += ch;
			quote = ch;
			continue;
		}
		if (/\s/.test(ch)) {
			if (current) tokens.push(unquote(current));
			current = "";
			continue;
		}
		current += ch;
	}
	if (current) tokens.push(unquote(current));
	return tokens;
}

function isTrustedTempVariableReference(token: string, temporaryVariables: ReadonlySet<string>): boolean {
	const match = /^\$(?:\{([A-Za-z_][A-Za-z0-9_]*)\}|([A-Za-z_][A-Za-z0-9_]*))$/.exec(token);
	return match !== null && temporaryVariables.has(match[1] ?? match[2]);
}

function isTmpOnlyFileOperation(segment: string, temporaryVariables: ReadonlySet<string>): boolean {
	const [command, ...args] = shellTokens(segment);
	if (!command) return false;
	const name = command.split("/").pop();
	if (!name) return false;

	const nonOptions = args.filter((arg) => arg !== "--" && !arg.startsWith("-"));
	if (nonOptions.length === 0) return false;
	const isTemporaryTarget = (target: string) =>
		isTmpPath(target) || isTrustedTempVariableReference(target, temporaryVariables);

	if (name === "rm" || name === "rmdir") return nonOptions.every(isTemporaryTarget);
	if (name === "cp" || name === "mv" || name === "ln") return nonOptions.every(isTemporaryTarget);
	if (name === "chmod" || name === "chown") {
		const pathArgs = nonOptions.slice(1);
		return pathArgs.length > 0 && pathArgs.every(isTemporaryTarget);
	}
	return false;
}

/** True for a direct `/tmp/...` assignment with a stable path prefix. */
function isTrustedTemporaryPathAssignment(value: string): boolean {
	const unquoted = unquote(value.trim());
	if (unquoted.includes("$(") || unquoted.includes("`")) return false;
	if (!unquoted.startsWith("/tmp/")) return false;

	// Require a fixed first path component. This permits names such as
	// /tmp/plan-${timestamp}.md, but not /tmp/$untrusted/path.
	return /^[A-Za-z0-9_-]+/.test(unquoted.slice("/tmp/".length));
}

/**
 * Tracks variables that are known to contain temporary paths within one bash
 * tool call. Trust only `$(mktemp)` or direct `/tmp/...` assignments; any later
 * assignment or `unset` revokes that trust.
 */
function temporaryVariablesBeforeSegments(segments: string[]): ReadonlySet<string>[] {
	const temporaryVariables = new Set<string>();
	const states: ReadonlySet<string>[] = [];

	for (const segment of segments) {
		states.push(new Set(temporaryVariables));
		const trimmed = segment.trim();
		const assignment = /^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$/.exec(trimmed);
		if (assignment) {
			const [, name, value] = assignment;
			if (
				value === "$(mktemp)" ||
				value === '"$(mktemp)"' ||
				isTrustedTemporaryPathAssignment(value)
			) {
				temporaryVariables.add(name);
			} else {
				temporaryVariables.delete(name);
			}
			continue;
		}

		const unset = /^unset\s+([A-Za-z_][A-Za-z0-9_]*)\s*$/.exec(trimmed);
		if (unset) temporaryVariables.delete(unset[1]);
	}

	return states;
}

export function redirectWriteTargets(command: string): string[] {
	const targets: string[] = [];
	let quote: "'" | '"' | undefined;
	let escaped = false;

	for (let i = 0; i < command.length; i++) {
		const ch = command[i];

		if (escaped) {
			escaped = false;
			continue;
		}
		if (ch === "\\") {
			escaped = true;
			continue;
		}
		if (quote) {
			if (ch === quote) quote = undefined;
			continue;
		}
		if (ch === "'" || ch === '"') {
			quote = ch;
			continue;
		}
		if (ch !== ">") continue;

		const prev = command[i - 1];
		if (prev === "<" || prev === ">" || prev === "&") continue;

		let opStart = i;
		while (opStart > 0 && /[0-9]/.test(command[opStart - 1])) opStart--;
		if (opStart > 0 && /[^\s|;&(]/.test(command[opStart - 1])) continue;

		let j = command[i + 1] === ">" ? i + 2 : i + 1;
		while (/\s/.test(command[j] ?? "")) j++;
		if (command[j] === "&") continue;

		const target = readShellToken(command, j);
		if (target) targets.push(unquote(target));
	}
	return targets;
}

function readShellToken(command: string, start: number): string | undefined {
	const quote = command[start];
	if (quote === "'" || quote === '"') {
		let escaped = false;
		for (let i = start + 1; i < command.length; i++) {
			const ch = command[i];
			if (escaped) {
				escaped = false;
				continue;
			}
			if (quote === '"' && ch === "\\") {
				escaped = true;
				continue;
			}
			if (ch === quote) return command.slice(start, i + 1);
		}
		return command.slice(start);
	}

	let end = start;
	while (end < command.length && !/[\s|;&<>()]/.test(command[end])) end++;
	return end > start ? command.slice(start, end) : undefined;
}

export function hasRiskyRedirect(command: string): boolean {
	return redirectWriteTargets(command).some((t) => !isBenignTarget(t));
}

const HARD_BLOCK_PATTERNS: RegExp[] = [
	/\b(?:sudo|doas|pkexec)\b/,
	/^\s*su(?:\s|$)/,
	/\b(?:mkfs|fdisk|parted|wipefs)\b/,
	/\bdd\b[\s\S]*\bof=\/dev\/(?:sd|hd|vd|xvd|nvme)[\w-]*/,
	/>\s*\/dev\/(?:sd|hd|vd|xvd|nvme)[\w-]*/,
	/:\(\)\s*\{\s*:\|:&\s*\}\s*;:/,
	/\b(?:shutdown|reboot|halt|poweroff)\b/,
	/\binit\s+0\b/,
	/\bkill\s+-9\s+1\b/,
	/\b(?:curl|wget)\b[\s\S]*\|\s*(?:env\s+)?(?:ba)?sh\b/,
	/\b(?:ba)?sh\s*<\s*\(\s*(?:curl|wget)\b/,
	/\b(?:\/bin\/)?rm\b(?=[\s\S]*-[A-Za-z]*r)(?=[\s\S]*-[A-Za-z]*f)[\s\S]*(?:^|\s|=)(?:--\s*)?(?:\/|\/\*|~|~\/|\$HOME|"\$HOME"|'\$HOME'|\.|\.\/\*)\s*$/,
	/\bchmod\b[\s\S]*(?:^|\s)(?:-R\s+)?777\s+\//,
	/\bchown\b[\s\S]*(?:^|\s)(?:-R\s+)?root(?::|\s)/,
];

function hardBlockReason(segment: string): string | undefined {
	const normalized = segment.replace(/\\\n/g, " ");
	const pattern = HARD_BLOCK_PATTERNS.find((p) => p.test(normalized));
	return pattern ? `matches hard block pattern ${pattern}` : undefined;
}

const SENSITIVE_PATH_PREFIXES = [
	"/etc/",
	"/usr/",
	"/bin/",
	"/sbin/",
	"/var/",
	"/dev/",
	"/proc/",
	"/sys/",
];

function pathPromptReason(path: string, cwd: string): string | undefined {
	const absolute = isAbsolute(path) ? path : resolve(cwd, path);
	if (isTmpPath(absolute)) return undefined;
	if (SENSITIVE_PATH_PREFIXES.some((prefix) => absolute === prefix.slice(0, -1) || absolute.startsWith(prefix))) {
		return `targets sensitive path ${absolute}`;
	}
	const root = resolve(cwd);
	if (absolute !== root && !absolute.startsWith(`${root}/`)) return `targets path outside cwd: ${absolute}`;
	return undefined;
}

export function analyzeDecision(
	toolName: string,
	subject: string,
	safe: string[],
	prompt: string[],
	block: string[] = [],
	cwd: string = process.cwd(),
): DecisionDetails {
	const label = TOOL_LABELS[toolName];
	if (!label) {
		return {
			decision: "allow",
			segments: [subject],
			deniedSegments: [],
			unmatchedSegments: [],
			riskyRedirectTargets: [],
			promptSegments: [],
			reasons: [],
		};
	}

	const safeGlobs = globsFor(safe, label);
	const promptGlobs = globsFor(prompt, label);
	const blockGlobs = globsFor(block, label);
	const rawSegments = toolName === "bash" ? splitCommand(subject) : [subject];
	const segments = toolName === "bash" ? rawSegments.map(stripRedirections) : rawSegments;
	const temporaryVariables = temporaryVariablesBeforeSegments(rawSegments);
	const riskyRedirectTargets =
		toolName === "bash"
			? rawSegments.flatMap((segment, index) =>
					redirectWriteTargets(segment).filter(
						(target) =>
							!isBenignTarget(target) &&
							!isTrustedTempVariableReference(target, temporaryVariables[index]),
					),
				)
			: [];
	const reasons: string[] = [];

	const wholeCommandBlockReason = toolName === "bash" ? hardBlockReason(subject) : undefined;
	if (wholeCommandBlockReason) {
		reasons.push(`${subject}: ${wholeCommandBlockReason}`);
		return {
			decision: "deny",
			segments,
			deniedSegments: [subject],
			unmatchedSegments: [],
			riskyRedirectTargets,
			promptSegments: [],
			reasons,
		};
	}

	const deniedSegments = segments.filter((seg) => {
		const reason = toolName === "bash" ? hardBlockReason(seg) : undefined;
		if (reason) {
			reasons.push(`${seg}: ${reason}`);
			return true;
		}
		return blockGlobs.some((g) => globMatches(g, seg));
	});

	if (deniedSegments.length > 0) {
		return {
			decision: "deny",
			segments,
			deniedSegments,
			unmatchedSegments: [],
			riskyRedirectTargets,
			promptSegments: [],
			reasons,
		};
	}

	const promptSegments = segments.filter((seg, index) => {
		if (safeGlobs.some((g) => globMatches(g, seg))) return false;
		if (toolName === "bash" && isTmpOnlyFileOperation(seg, temporaryVariables[index])) return false;
		return promptGlobs.some((g) => globMatches(g, seg));
	});

	if ((toolName === "write" || toolName === "edit") && segments[0]) {
		const reason = pathPromptReason(segments[0], cwd);
		if (reason) {
			promptSegments.push(segments[0]);
			reasons.push(reason);
		}
	}

	if (segments.length === 0) reasons.push("empty command");
	for (const target of riskyRedirectTargets) reasons.push(`write redirect to ${target}`);

	const shouldPrompt = segments.length === 0 || promptSegments.length > 0 || riskyRedirectTargets.length > 0;
	return {
		decision: shouldPrompt ? "prompt" : "allow",
		segments,
		deniedSegments: [],
		unmatchedSegments: promptSegments,
		riskyRedirectTargets,
		promptSegments,
		reasons,
	};
}

export function decide(
	toolName: string,
	subject: string,
	safe: string[],
	prompt: string[],
	block: string[] = [],
	cwd?: string,
): Decision {
	return analyzeDecision(toolName, subject, safe, prompt, block, cwd).decision;
}

/** Suggest a starting pattern for prompt/block override saves. */
export function suggestPattern(toolName: string, subject: string): string {
	const label = TOOL_LABELS[toolName] ?? "Bash";
	if (toolName === "bash") {
		const first = splitCommand(subject)[0] ?? subject.trim();
		const firstWord = first.split(/\s+/)[0] ?? first;
		return `${label}(${firstWord} *)`;
	}
	return `${label}(${subject})`;
}
