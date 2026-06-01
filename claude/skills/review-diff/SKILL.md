---
name: review-diff
description: >
  Present a git diff to the user for inline annotation via the review-plan UI.
  Use when you want to review code changes before committing or requesting review.
---

You are presenting a git diff for human review using the review-plan CLI.

## Steps

1. Get the diff you want to review. For staged changes use `git diff --staged`;
   for all uncommitted changes use `git diff HEAD`; for a specific range use
   `git diff <base>..<head>`.
   **Note**: Run `git add -N .` first to include untracked files in the diff. This records the intent to add the files, making them visible to `git diff` without fully staging them.
2. Run the CLI, piping the diff to stdin:
   ```
   git diff HEAD | review-plan diff --comments-only --title "<short task-specific title>" --theme light
   ```
   Always use `--theme light` and `--comments-only` — the diff is already in your context, echoing it back wastes tokens.
3. Wait for the CLI to exit. It blocks until the user clicks Done.
4. If the CLI prints nothing to stdout, the user had no comments — proceed.
5. If the CLI prints annotated output, read each comment carefully and address it in code.
   Commit any fixes and re-run the skill if the user asked for another review pass.

## Notes

- Always pass `--title`. Derive it from the branch name or the work being done (e.g. "Auth middleware changes", "Dark mode CSS") — never use a generic title like "Diff review".
- Always pass `--theme light`.
- If the diff is very large (hundreds of files), warn the user before opening and offer to scope it to specific paths: `git diff HEAD -- src/`.
- `--comments-only` is always passed. It omits the full diff from the output and returns only the comment summary, since the diff is already in your context.
