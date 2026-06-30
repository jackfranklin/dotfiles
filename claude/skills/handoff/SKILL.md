---
disable-model-invocation: true
name: handoff
description: Summarize the current conversation and save it as a GitHub Issue with a [HANDOFF] prefix, or update an existing one. Use this when you want to hand off the current state or update progress.
---

To perform or update a handoff:

1. Verify there is a GitHub remote for the current repo. Run `gh repo view --json nameWithOwner` — if it fails, stop and tell the user there is no GitHub remote.
2. Generate a very short name for this task if not already established (e.g., `setup-handoff-skill`).
3. Check for an existing handoff issue: `gh issue list --search "[HANDOFF] <short-name>" --state open --json number,title,url`. If a match is found, read its current body with `gh issue view <number> --json body`.
4. Compose the issue content covering:
   - **Summary**: A single-line summary of the current state and goal.
   - **Original Goal**: What was the user trying to achieve?
   - **Current Status**: What has been completed so far?
   - **Next Steps**: High-level objectives or next areas of focus.
   - **Key Decisions & Context**: Non-obvious decisions or important context.
   - **Relevant Files**: Files created, modified, or central to the task.
5. If **creating** a new issue:
   ```
   gh issue create --title "[HANDOFF] <short-name>" --body "<content>"
   ```
6. If **updating** an existing issue, append a timestamped update section and edit the issue:
   ```
   gh issue edit <number> --body "<updated-content>"
   ```
   Prefix all updates with a timestamp (e.g., `[2026-06-01 11:49]`). Prefer appending new information rather than replacing existing content.
7. Inform the user the handoff has been recorded/updated and provide the issue URL.
