---
disable-model-invocation: true
name: handoff
description: Manage and search session handoffs, plans, and conversation summaries. Supports saving progress, listing previous handoffs, or generating a scannable chat summary.
---

# Handoff & Session Management

Use this skill when you want to summarize, save, or resume the state of your work. It supports three distinct operations based on the user's request:

- **Save / Update Handoff**: Write/update a progress summary file in `.jai/`.
- **Search / List Handoffs**: Scan `.jai/` to find and resume work from a previous session.
- **Summarize**: Generate a scannable conversation summary directly in the chat window.

---

## 1. Save / Update Handoff
Use when the user wants to "save progress", "update the handoff", or "write a handoff".

1. Determine if this handoff represents a **long-lived project plan** (e.g., architecture, roadmap spanning multiple weeks/conversations) or a **short-lived conversation handoff** (capturing state for the next session). If the context makes this distinction unclear, ask the user for clarification.
2. Generate a very short name for this task/plan if not already established (e.g., `setup-handoff-skill`).
3. Determine the target folder and file name format based on the category:
    - **Project Plan**: Save to `.jai/plans/<short-name>.md`.
    - **Conversation Handoff**: Save to `.jai/conversations/YYYY-MM-DD-<short-name>.md`.
4. Check if a matching file already exists in the target subdirectory.
5. If an existing file is found:
    - Read its content to understand the current state.
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

---

## 2. Search / List Handoffs
Use when the user wants to "find handoffs", "resume work", or "list conversations".

1. Look for a directory named `.jai` in the current working directory. If it doesn't exist, inform the user that no saved handoffs or plans were found.
2. List all markdown files (`*.md`) inside `.jai/conversations/` and `.jai/plans/`.
3. For each file found, read its content to extract the `**Summary**:` section (typically in the first few lines).
4. Present the list of files categorized under two distinct sections:
    - **Active Plans** (files from `.jai/plans/`)
    - **Recent Conversations** (files from `.jai/conversations/`)
    Include the filename and its summary for each.
5. If the user or context implies a specific topic, recommend the most relevant file from either category.
6. Once the correct file is identified, read its full content to load the context.

---

## 3. Summarize Conversation
Use when the user requests a summary of the current conversation without writing to disk, or when the context window is filling up and needs to be summarized before clearing.

1. Analyze the conversation history (including recent queries, actions, and the transcript) to identify:
   - **Goal/Context**: What was the primary objective of this session?
   - **Completed Tasks**: What tasks, changes, or files were successfully implemented or analyzed?
   - **Open items / Next steps**: What was left incomplete or needs to be addressed in the next session?
   - **Key decisions & technical context**: Any constraints, patterns discovered, or design choices made.
   - **Key files**: List of main files modified, created, or read.
2. Present a succinct markdown-formatted summary directly in the chat response. Write from a neutral, objective, third-person perspective (avoiding "I", "me", "you", or "we"). This makes the summary suitable for copy-pasting directly into bug trackers, pull requests, or code review comments.
3. Start directly with the content or sub-sections without a top-level main heading (e.g., do not include a title like `# Summary` or `### Conversation Summary` at the start).
4. If subheadings are required within the summary to group details, use smaller headings like H4 (`####`) rather than larger ones like H1, H2, or H3.
5. Avoid local file links (like `[file.ts](file:///...)`) or absolute system paths. Reference files, classes, and methods as plain text with inline code backticks (e.g., `ExportConversation.ts`).
6. Keep the summary under 150-200 words, using bullet points for readability.
7. Avoid conversational filler or meta-commentary. Just print the markdown block.
