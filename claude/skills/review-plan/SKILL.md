---
disable-model-invocation: true
name: review-plan
description: >
  Present a plan to the user for inline annotation via the ai-review UI.
  Use when you have a plan ready for human review before executing it.
  The user will annotate it in the browser; you then revise based on their comments.
---

You are presenting a plan for human review using the ai-review CLI.

## Steps

1. Write the plan to a temp file at `/tmp/plan-<timestamp>.md`.
2. Run the CLI with a title and theme. Choose a title that is short (3–6 words)
   and specific to the current task — the user may have multiple review tabs open
   at once and needs to tell them apart at a glance:
   ```
   node ~/git/ai-review-plan/dist/cli.js plan --title "<short task-specific title>" --theme <dark|light> /tmp/plan-<timestamp>.md
   ```
   Use `--theme light` unless the user has expressed a preference for dark mode.
3. Once the CLI launches, check its initial output (e.g. `Opening http://localhost:<port>`) and tell the user what port the review is active on. Wait for the CLI to exit. It blocks until the user submits their review.
4. Check the exit code and stdout:
   - **Exit 0 (Approved):** The user approved the plan. Check for any inline comments and address them, then proceed.
   - **Exit 1 (Changes Requested):** The user requested changes. Do not proceed. Show the user the comments from stdout and revise the plan to address them, then offer to run another review pass.
5. The stdout always begins with `## Review: APPROVED` or `## Review: CHANGES REQUESTED`, followed by any comments as a numbered list. Read each comment carefully.
6. Delete the temporary file.

## Notes

- Always pass `--title`. Derive it from the current conversation (e.g. "Auth middleware refactor", "Add dark mode", "DB migration plan") — never use a generic title like "Plan review".
- Always pass `--theme`. Default to `light`; switch to `dark` if the user has indicated a preference.
- Do not proceed with execution until after review is complete and the verdict is Approved.
- If the user's comments conflict with each other, surface the conflict and ask for clarification rather than guessing.
- **Diagrams**: Use Mermaid diagrams (e.g. `sequenceDiagram`, `flowchart TD`, `stateDiagram-v2` in a fenced code block with language `mermaid`) when explaining complex interactions, database schemas, architectures, or step-by-step processes to make the plan easier to review.
