---
name: review-plan
description: >
  Present a plan to the user for inline annotation via the review-plan UI.
  Use when you have a plan ready for human review before executing it.
  The user will annotate it in the browser; you then revise based on their comments.
---

You are presenting a plan for human review using the review-plan CLI.

## Steps

1. Write the plan to a temporary file (e.g. `/tmp/plan-<timestamp>.md`).
2. Resolve the binary: if `~/git/ai-plan-reviewer/dist/cli.js` exists, use
   `node ~/git/ai-plan-reviewer/dist/cli.js`; otherwise use `review-plan`.
3. Run the CLI with a title and theme. Choose a title that is short (3–6 words)
   and specific to the current task — the user may have multiple review tabs open
   at once and needs to tell them apart at a glance:
   ```
   <bin> plan --comments-only --title "<short task-specific title>" --theme light /tmp/plan-<timestamp>.md
   ```
   Always use `--theme light` and `--comments-only` — the plan is already in your context, echoing it back wastes tokens.
4. Wait for the CLI to exit. It blocks until the user clicks Done.
5. If the CLI prints nothing to stdout, the user had no comments — proceed with the plan as-is.
6. If the CLI prints annotated output, read each comment carefully and revise the plan to address it. Show the revised plan to the user before proceeding.
7. Delete the temporary file.

## Notes

- Always pass `--title`. Derive it from the current conversation (e.g. "Auth middleware refactor", "Add dark mode", "DB migration plan") — never use a generic title like "Plan review".
- Always pass `--theme light`.
- Do not proceed with execution until after review is complete.
- If the user's comments conflict with each other, surface the conflict and ask for clarification rather than guessing.
