---
disable-model-invocation: true
name: handoff
description: Summarize the current conversation, generate a short name for it, and save it or update an existing handoff in the .jai folder. Use this when you want to hand off the current state or update progress.
---

To perform or update a handoff:
1. Determine if this handoff represents a **long-lived project plan** (e.g., architecture, roadmap spanning multiple weeks/conversations) or a **short-lived conversation handoff** (capturing state for the next session). If the context makes this distinction unclear, ask the user for clarification.
2. Generate a very short name for this task/plan if not already established (e.g., `setup-handoff-skill`).
3. Determine the target folder and file name format based on the category:
    - **Project Plan**: Save to `.jai/plans/<short-name>.md`.
    - **Conversation Handoff**: Save to `.jai/conversations/YYYY-MM-DD-<short-name>.md`.
4. Check if a matching file already exists in the target subdirectory.
5. If an existing file is found:
    - Read its content to understand current state.
    - If the file is large (e.g., > 100 lines), ask the user for permission to append or if they prefer creating a new file.
    - When updating, prefer appending new information to the relevant sections rather than replacing existing content.
    - Prefix all updates with a timestamp (e.g., `[2026-06-01 11:49]`).
6. If creating a new file or appending to an existing one, ensure the content covers:
    - **Summary**: A single-line summary of the current state and goal.
    - **Original Goal**: What was the user trying to achieve?
    - **Current Status**: What has been completed so far?
    - **Next Steps**: High-level objectives or next areas of focus.
    - **Key Decisions & Context**: Non-obvious decisions or important context.
    - **Relevant Files**: Files created, modified, or central to the task.
7. Ensure the target directory exists before writing.
8. Inform the user that the handoff or plan has been recorded/updated and provide the file path.

