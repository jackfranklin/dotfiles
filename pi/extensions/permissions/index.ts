/**
 * Custom permission gate for pi.
 *
 * Allowlists/denylists tool calls (bash, read, write, edit) using glob-style
 * entries stored in ~/.pi/agent/permissions.json. Anything not matched prompts
 * the user with: Allow once / Allow always / Ban once / Ban always. The
 * "always" options persist a (editable) pattern to the store.
 *
 * See store.ts / matcher.ts / glob.ts for the pieces.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { decide, suggestPattern, TOOL_LABELS } from "./matcher.ts";
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

		const verdict = decide(event.toolName, subject, store.allow, store.deny);

		if (verdict === "allow") return undefined;
		if (verdict === "deny") {
			return { block: true, reason: `Blocked by permissions denylist: ${label}(${subject})` };
		}

		// verdict === "prompt"
		if (!ctx.hasUI) {
			return { block: true, reason: "Not in allowlist and no UI available to confirm" };
		}

		const header = `Permission needed:\n\n  ${label}: ${subject}\n\nWhat would you like to do?`;
		const choice = await ctx.ui.select(header, [
			"Allow once",
			"Allow always",
			"Ban once",
			"Ban always",
		]);

		switch (choice) {
			case "Allow once":
				return undefined;

			case "Allow always": {
				const pattern = await promptPattern(ctx.ui, event.toolName, subject);
				if (pattern) store.addAllow(pattern);
				return undefined;
			}

			case "Ban always": {
				const pattern = await promptPattern(ctx.ui, event.toolName, subject);
				if (pattern) store.addDeny(pattern);
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
	if (/^\w+\(.*\)$/s.test(trimmed)) return trimmed;
	const label = TOOL_LABELS[toolName] ?? "Bash";
	return `${label}(${trimmed})`;
}
