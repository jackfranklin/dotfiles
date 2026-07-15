/**
 * Matching logic: given the gated tool and its subject (bash command or file
 * path), decide whether it is allowed, denied, or needs to be prompted.
 */
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

/**
 * Normalise shell syntax down to the simple command that actually runs.
 *
 * This intentionally understands only common compound-command scaffolding. For
 * example, `for f in *; do grep x "$f" || echo "$f"; done` becomes the two
 * command segments `grep x "$f"` and `echo "$f"`; the loop keywords are not
 * useful permission subjects. If a skipped header contains command
 * substitution, keep it so the command prompts rather than hiding work.
 */
function normalizeShellSegment(segment: string): string | undefined {
	let s = segment.trim();
	if (!s) return undefined;

	// Pure shell-control words are not commands by themselves.
	if (/^(?:do|done|then|fi|esac|\{|\})$/.test(s)) return undefined;

	// `else echo x` / `then echo x` / `do echo x` all run the trailing command.
	s = s.replace(/^(?:do|then|else)\s+/, "").trim();
	if (!s) return undefined;

	// `if grep ...; then` and `while grep ...; do` run their condition command.
	s = s.replace(/^(?:if|while|until)\s+/, "").trim();
	if (!s) return undefined;

	// A `for name in words` header expands words but does not execute a command,
	// unless those words contain command substitution. Prompt in that case.
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

/** Redirection targets that are never a real filesystem write we care about. */
const BENIGN_REDIRECT_TARGETS = new Set(["/dev/null", "/dev/stdout", "/dev/stderr"]);

function isBenignTarget(target: string): boolean {
	return BENIGN_REDIRECT_TARGETS.has(target) || target.startsWith("/dev/fd/");
}

/**
 * Remove all shell redirections (read and write) from a command so the
 * remaining text is just the commands + args to match against globs. Handles
 * forms like `> f`, `>> f`, `2> f`, `&> f`, `2>&1`, `< f`, `<<< s`. Quoting is
 * not fully parsed; worst case this over-strips and causes an extra prompt.
 */
function stripRedirections(command: string): string {
	const redir =
		/(?:[0-9]+|&)?(?:>>?|<<?<?)\s*(?:&[0-9-]+|"[^"]*"|'[^']*'|[^\s|;&<>()]+)?/g;
	return command.replace(redir, " ");
}

/** Unquote a captured redirection target. */
function unquote(token: string): string {
	if (
		(token.startsWith('"') && token.endsWith('"')) ||
		(token.startsWith("'") && token.endsWith("'"))
	) {
		return token.slice(1, -1);
	}
	return token;
}

/**
 * Collect the targets of write redirections (`>`, `>>`, `2>`, `&>`) in a
 * command. File-descriptor duplications like `2>&1` and `>&2` are not writes to
 * a file, so they are excluded.
 */
export function redirectWriteTargets(command: string): string[] {
	const re = /(?:^|[^<>&\d])(?:[0-9]+|&)?>>?\s*("[^"]*"|'[^']*'|[^\s|;&<>()]+)/g;
	const targets: string[] = [];
	let m: RegExpExecArray | null;
	while ((m = re.exec(command)) !== null) {
		targets.push(unquote(m[1]));
	}
	return targets;
}

/**
 * True if the command writes (via `>`/`>>`) to a real file, as opposed to
 * `/dev/null` and friends or a bare fd duplication. Such writes should always
 * prompt, since the target file is not covered by the command's allow glob.
 */
export function hasRiskyRedirect(command: string): boolean {
	return redirectWriteTargets(command).some((t) => !isBenignTarget(t));
}

/**
 * Decide for a tool call.
 *   - bash: every segment must be allowed to allow; any denied segment denies.
 *   - other tools: the single subject (a path) is matched directly.
 * Deny always wins over allow.
 */
export function analyzeDecision(
	toolName: string,
	subject: string,
	allow: string[],
	deny: string[],
): DecisionDetails {
	const label = TOOL_LABELS[toolName];
	if (!label) {
		return {
			decision: "allow",
			segments: [subject],
			deniedSegments: [],
			unmatchedSegments: [],
			riskyRedirectTargets: [],
		};
	}

	const allowGlobs = globsFor(allow, label);
	const denyGlobs = globsFor(deny, label);

	// For bash, strip redirections before matching so `>`/`<` targets don't
	// pollute the command segments (and get re-checked separately below).
	const segments = toolName === "bash" ? splitCommand(stripRedirections(subject)) : [subject];
	const deniedSegments = segments.filter((seg) => denyGlobs.some((g) => globMatches(g, seg)));
	const unmatchedSegments = segments.filter((seg) => !allowGlobs.some((g) => globMatches(g, seg)));
	const riskyRedirectTargets =
		toolName === "bash" ? redirectWriteTargets(subject).filter((t) => !isBenignTarget(t)) : [];

	let decision: Decision = "prompt";
	if (deniedSegments.length > 0) {
		decision = "deny";
	} else if (segments.length > 0 && unmatchedSegments.length === 0 && riskyRedirectTargets.length === 0) {
		decision = "allow";
	}

	return { decision, segments, deniedSegments, unmatchedSegments, riskyRedirectTargets };
}

export function decide(
	toolName: string,
	subject: string,
	allow: string[],
	deny: string[],
): Decision {
	return analyzeDecision(toolName, subject, allow, deny).decision;
}

/** Suggest a starting pattern for "save always" prompts. */
export function suggestPattern(toolName: string, subject: string): string {
	const label = TOOL_LABELS[toolName] ?? "Bash";
	if (toolName === "bash") {
		const first = splitCommand(subject)[0] ?? subject.trim();
		const firstWord = first.split(/\s+/)[0] ?? first;
		return `${label}(${firstWord} *)`;
	}
	return `${label}(${subject})`;
}
