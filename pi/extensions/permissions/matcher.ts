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

/**
 * Split a bash command into independently-executed segments on shell control
 * operators: && || ; | & and newlines. Quoting is NOT parsed, so an operator
 * inside a quoted string will over-split — that only ever causes an extra
 * prompt, never a bypass.
 */
export function splitCommand(command: string): string[] {
	return command
		.split(/(?:&&|\|\||;|\||&|\n)/)
		.map((s) => s.trim())
		.filter((s) => s.length > 0);
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
export function decide(
	toolName: string,
	subject: string,
	allow: string[],
	deny: string[],
): Decision {
	const label = TOOL_LABELS[toolName];
	if (!label) return "allow"; // ungated tool

	const allowGlobs = globsFor(allow, label);
	const denyGlobs = globsFor(deny, label);

	// For bash, strip redirections before matching so `>`/`<` targets don't
	// pollute the command segments (and get re-checked separately below).
	const segments = toolName === "bash" ? splitCommand(stripRedirections(subject)) : [subject];
	if (segments.length === 0) return "prompt";

	// Deny wins: if any segment is explicitly denied, block.
	if (segments.some((seg) => denyGlobs.some((g) => globMatches(g, seg)))) {
		return "deny";
	}

	// A write to a real file is never covered by a command's allow glob.
	if (toolName === "bash" && hasRiskyRedirect(subject)) {
		return "prompt";
	}

	// Allow only if every segment is covered by an allow glob.
	if (segments.every((seg) => allowGlobs.some((g) => globMatches(g, seg)))) {
		return "allow";
	}

	return "prompt";
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
