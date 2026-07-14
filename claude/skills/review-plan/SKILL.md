---
disable-model-invocation: true
name: review-plan
description: >
  Present a plan to the user for inline annotation via the ai-review UI.
  Use when you have a plan ready for human review before executing it.
  The user will annotate it in the browser; you then revise based on their comments.
---

You are presenting a plan for human review using the ai-review CLI, in
**interactive mode**: the CLI stays running across multiple rounds, and you
revise the plan file in place instead of restarting the CLI for each pass.

## Steps

1. Write the plan to a file in the `/tmp/` directory (e.g. `/tmp/plan-<timestamp>.md`).

2. **Generate AI annotations.** Before opening the review, write a JSON file with a summary and any per-line notes to guide the reviewer. This is especially useful on later rounds to show what changed since the last one.

   Write the file to `/tmp/annotations-<timestamp>.json` using this schema:
   ```json
   {
     "summary": "One or two sentences: what this plan does, or what changed since the last round.",
     "annotations": [
       {
         "startLine": 15,
         "endLine": 22,
         "text": "This section was rewritten to address the feedback about error handling."
       }
     ]
   }
   ```

   Rules for generating annotations:
   - `summary` is optional but strongly recommended; always write one after the first round.
   - `annotations` is optional; include only lines worth drawing the reviewer's attention to.
   - Do **not** include a `file` field — plan mode uses plain line numbers only.
   - `startLine` and `endLine` are **1-indexed line numbers in the plan file**. To get accurate numbers: read the written plan file back with line numbers (e.g. `cat -n /tmp/plan-<timestamp>.md`), then reference the specific lines.
   - Fenced code blocks and tables are treated as a single block. Annotating any line inside a code fence attaches the annotation to the opening ` ``` ` line. If you want to annotate content within a fence, use the line number of the opening fence.
   - Read the written annotations file back and verify line numbers look correct before proceeding. If annotations don't appear in the review UI, they were silently dropped with no error — check that line numbers fall within the rendered content.

3. Start the CLI **in the background** with `--interactive`, so you can keep working while it stays open across rounds. Choose a title that is short (3–6 words) and specific to the current task — the user may have multiple review tabs open at once and needs to tell them apart at a glance:
   ```
   node ~/git/ai-review-plan/dist/cli.js plan \
     --title "<short task-specific title>" \
     --theme <dark|light> \
     --ai-annotations-file /tmp/annotations-<timestamp>.json \
     --interactive \
     /tmp/plan-<timestamp>.md
   ```
   Use `--theme light` unless the user has expressed a preference for dark mode.

4. Wait for stdout to print `Watching: <path>` — this confirms the server is up and the browser has been asked to open. The process keeps running after this; do not wait for it to exit.

5. Keep monitoring the background process's stdout by polling:
   - Schedule a 10-second timer using the `schedule` tool (e.g., `DurationSeconds="10"`, `TimerCondition="never"`).
   - When the timer fires, check the background task's status using `manage_task` with action `status`, read its log file using `view_file`, and inspect the latest output.
   - If no new output or feedback is present, immediately schedule another 10-second timer to continue polling.
   - Each round ends in one of three ways:
     - **`=== FEEDBACK END ===`** / **`[ACTION REQUIRED]`** — the user clicked **Request Changes**. The stdout since the last marker contains the `## Review: CHANGES REQUESTED` comments. **You must act immediately and autonomously. Do not wait for a user chat prompt or command termination.** Read the comments carefully, revise the plan file **in place at its original path** (do not write a new file — the CLI is watching that exact path), and optionally rewrite the annotations file with an updated summary describing what you just changed. Once you save the file, the changes are automatically sent to the browser. Then go back to waiting on stdout.
     - **The process exits with code 0** — the user clicked **Approve**. Stdout will contain `## Review: APPROVED` and any final comments; check for inline comments and address them, then proceed. This ends the review — go to step 6.
     - **`=== SESSION CLOSED: client disconnected ===`** (process exits non-zero) — the browser tab didn't reconnect within 30 seconds (e.g. the user closed it without submitting). Tell the user the session closed and ask whether to re-open it (re-run from step 3 against the same plan file) or stop here.

   > [!IMPORTANT]
   > When the user clicks **Request Changes**, the CLI does **not** exit. It prints `=== FEEDBACK END ===` and a `[ACTION REQUIRED]` block, then continues running. You must **not** wait for a user chat prompt or command termination. You must immediately read the printed feedback, perform the required code/plan changes, save the file, and resume monitoring stdout.

6. The stdout for each round always begins with `## Review: APPROVED` or `## Review: CHANGES REQUESTED`, followed by any comments as a numbered list. Read each comment carefully before revising.

7. Once the session has ended (approved, or the user confirms they're done), delete both temporary files (plan and annotations).

## Notes

- Always pass `--title`. Derive it from the current conversation (e.g. "Auth middleware refactor", "Add dark mode", "DB migration plan") — never use a generic title like "Plan review".
- Always pass `--theme`. Default to `light`; switch to `dark` if the user has indicated a preference.
- Pass `--no-wrap` to disable line wrapping if you prefer lines to overflow with a scrollbar. Line wrapping is enabled by default.
- Do not proceed with execution until the session ends with an Approved verdict.
- If the user's comments conflict with each other, surface the conflict and ask for clarification rather than guessing.
- **Diagrams**: Use Mermaid diagrams (e.g. `sequenceDiagram`, `flowchart TD`, `stateDiagram-v2` in a fenced code block with language `mermaid`) when explaining complex interactions, database schemas, architectures, or step-by-step processes to make the plan easier to review.
