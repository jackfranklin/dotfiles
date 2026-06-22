---
name: review-diff
description: >
  Present a git diff to the user for inline annotation via the ai-review UI.
  Use when you want to review code changes before committing or requesting review.
---

You are presenting a git diff for human review using the ai-review CLI.

## Steps

1. Get the diff you want to review. For staged changes use `git diff --staged`;
   for all uncommitted changes use `git diff HEAD`; for a specific range use
   `git diff <base>..<head>`.
   **Note**: Run `git add -N .` first to include untracked files in the diff. This records the intent to add the files, making them visible to `git diff` without fully staging them.
2. Run the CLI, piping the diff to stdin:
   ```bash
   git diff HEAD | node ~/git/ai-review-plan/dist/cli.js diff --title "<short task-specific title>" --theme <dark|light>
   ```
   Use `--theme light` unless the user has expressed a preference for dark mode.
3. Wait for the CLI to exit. It blocks until the user submits their review.
4. Check the exit code and stdout:
   - **Exit 0 (Approved):** The user approved the diff. Address any inline comments in code, then proceed.
   - **Exit 1 (Changes Requested):** The user requested changes. Do not commit or push. Show the user the comments from stdout, address them in code, and offer to run another review pass.
5. The stdout always begins with `## Review: APPROVED` or `## Review: CHANGES REQUESTED`, followed by any comments as a numbered list. Read each comment carefully.

## Notes

- Always pass `--title`. Derive it from the branch name or the work being done (e.g. "Auth middleware changes", "Dark mode CSS") — never use a generic title like "Diff review".
- Always pass `--theme`. Default to `light`; switch to `dark` if the user has indicated a preference.
- If the diff is very large (hundreds of files), warn the user before opening and offer to scope it to specific paths: `git diff HEAD -- src/`.
