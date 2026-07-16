/**
 * Custom permission gate for pi.
 *
 * Risk-gates tool calls (bash, read, write, edit) using glob-style entries
 * stored in ~/.pi/agent/permissions.json. Definitely dangerous calls are
 * blocked; risky middle-ground calls prompt in interactive sessions and block
 * in headless/subagent sessions; everything else is allowed.
 *
 * See store.ts / matcher.ts / glob.ts for the pieces.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { analyzeDecision, suggestPattern, TOOL_LABELS } from "./matcher.ts";
import { PermissionStore } from "./store.ts";

/** Extract the subject we match against for a given tool. */
function subjectFor(toolName: string, input: Record<string, unknown>): string | undefined {
	if (toolName === "bash") return typeof input.command === "string" ? input.command : undefined;
	// read / write / edit all take `path`.
	return typeof input.path === "string" ? input.path : undefined;
}

export default function (pi: ExtensionAPI) {
	const store = new PermissionStore();

	pi.on("tool_call", async (event, ctx) => {
		const label = TOOL_LABELS[event.toolName];
		if (!label) return undefined; // ungated tool

		const subject = subjectFor(event.toolName, event.input as Record<string, unknown>);
		if (subject === undefined) return undefined;

		const analysis = analyzeDecision(event.toolName, subject, store.safe, store.prompt, store.block);

		if (analysis.decision === "allow") return undefined;
		if (analysis.decision === "deny") {
			const denied = formatList(analysis.deniedSegments);
			const reasons = formatList(analysis.reasons);
			return {
				block: true,
				reason: `Blocked by permissions safety policy: ${label}(${subject})${denied ? `\n\nBlocked segment(s):\n${denied}` : ""}${reasons ? `\n\nReason(s):\n${reasons}` : ""}`,
			};
		}

		// analysis.decision === "prompt"
		if (!ctx.hasUI) {
			return { block: true, reason: "Command requires approval and no UI is available to confirm" };
		}

		const missingBareEntries = suggestMissingBareCommandEntries(
			event.toolName,
			analysis.unmatchedSegments,
			store.safe,
		);
		const addMissingBareChoice = formatAddMissingBareChoice(missingBareEntries);
		const header = `Approval needed:\n\n  ${label}: ${subject}${formatPromptDetails(analysis, missingBareEntries)}\n\nWhat would you like to do?`;
		const choices = [
			...(addMissingBareChoice ? [addMissingBareChoice] : []),
			"Allow once",
			"Allow always",
			"Ban once",
			"Ban always",
		];
		const choice = await ctx.ui.select(header, choices);

		if (addMissingBareChoice && choice === addMissingBareChoice) {
			for (const entry of missingBareEntries) store.addSafe(entry);
			return undefined;
		}

		switch (choice) {
			case "Allow once":
				return undefined;

			case "Allow always": {
				const pattern = await promptPattern(ctx.ui, event.toolName, subject);
				if (pattern) store.addSafe(pattern);
				return undefined;
			}

			case "Ban always": {
				const pattern = await promptPattern(ctx.ui, event.toolName, subject);
				if (pattern) store.addBlock(pattern);
				return { block: true, reason: `Banned by user: ${pattern ?? subject}` };
			}

			// "Ban once", cancelled (undefined), or anything unexpected: block once.
			default:
				return { block: true, reason: "Blocked by user" };
		}
	});
}

interface EditorUI {
	editor: (title: string, prefill?: string) => Promise<string | undefined>;
}

interface PromptAnalysis {
	unmatchedSegments: string[];
	riskyRedirectTargets: string[];
	reasons: string[];
}

function formatPromptDetails(analysis: PromptAnalysis, missingBareEntries: string[] = []): string {
	const parts: string[] = [];
	const unmatched = formatList(analysis.unmatchedSegments);
	if (unmatched) parts.push(`Risky segment(s) requiring approval:\n${unmatched}`);
	const missingBare = formatList(missingBareEntries);
	if (missingBare) {
		parts.push(
			`Possible fix: you already allow the same command with arguments; add bare-command entr${missingBareEntries.length === 1 ? "y" : "ies"}:\n${missingBare}`,
		);
	}
	const redirects = formatList(analysis.riskyRedirectTargets);
	if (redirects) parts.push(`Write redirect target(s) requiring approval:\n${redirects}`);
	const reasons = formatList(analysis.reasons);
	if (reasons) parts.push(`Reason(s):\n${reasons}`);
	return parts.length ? `\n\n${parts.join("\n\n")}` : "";
}

function formatAddMissingBareChoice(entries: string[]): string | undefined {
	if (entries.length === 0) return undefined;
	if (entries.length === 1) return `Add ${entries[0]} and allow once`;
	return `Add ${entries.length} bare-command entries and allow once`;
}

/**
 * If a bare command like `sort` prompts but `Bash(sort *)` is marked safe,
 * suggest adding the explicit no-arg form `Bash(sort)`. We keep this as a
 * prompt-time suggestion rather than making `x *` imply `x`, because no-arg
 * forms can have different behaviour for commands like `make` or `just`.
 */
export function suggestMissingBareCommandEntries(
	toolName: string,
	unmatchedSegments: string[],
	allow: string[],
): string[] {
	const label = TOOL_LABELS[toolName];
	if (toolName !== "bash" || !label) return [];

	const suggestions: string[] = [];
	for (const segment of unmatchedSegments) {
		if (!isBareCommandSegment(segment)) continue;
		const bareEntry = `${label}(${segment})`;
		const argsEntry = `${label}(${segment} *)`;
		if (allow.includes(argsEntry) && !allow.includes(bareEntry) && !suggestions.includes(bareEntry)) {
			suggestions.push(bareEntry);
		}
	}
	return suggestions;
}

function isBareCommandSegment(segment: string): boolean {
	return /^[^\s;&|()<>]+$/.test(segment);
}

function formatList(items: string[]): string {
	return items.map((item) => `  - ${item}`).join("\n");
}

/**
 * Ask the user to confirm/edit the pattern to persist. The suggested pattern is
 * prefilled and fully editable (via `editor`, unlike `input` whose second arg is
 * only a grey placeholder). Returns the normalized entry, or undefined if the
 * user cleared/cancelled.
 */
async function promptPattern(
	ui: EditorUI,
	toolName: string,
	subject: string,
): Promise<string | undefined> {
	const suggestion = suggestPattern(toolName, subject);
	const answer = await ui.editor("Save as pattern (edit to generalize):", suggestion);
	return normalizeEntry(answer, toolName);
}

/**
 * Ensure a saved entry has the `Tool(glob)` wrapper. If the user typed a bare
 * glob (e.g. `ls *`), wrap it with the current tool's label so it actually
 * matches. Returns undefined for empty/cancelled input.
 */
export function normalizeEntry(answer: string | undefined, toolName: string): string | undefined {
	const trimmed = answer?.trim();
	if (!trimmed) return undefined;

	const wrapped = /^(\w+)\((.*)\)$/s.exec(trimmed);
	if (wrapped) {
		const label = canonicalToolLabel(wrapped[1]);
		return label ? `${label}(${wrapped[2]})` : trimmed;
	}

	const label = canonicalToolLabel(toolName) ?? "Bash";
	return `${label}(${trimmed})`;
}

function canonicalToolLabel(toolNameOrLabel: string): string | undefined {
	const normalized = toolNameOrLabel.toLowerCase();
	const label = TOOL_LABELS[normalized] ?? toolNameOrLabel;
	return Object.values(TOOL_LABELS).find((knownLabel) => knownLabel.toLowerCase() === label.toLowerCase());
}
