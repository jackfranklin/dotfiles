---
name: handoff-search
description: Find and list handed off conversations in the current workspace to resume work.
---

To find a handoff or plan doc:
1. Look for a directory named `.jai` in the current working directory.
2. If it doesn't exist, inform the user that no saved handoffs or plans were found.
3. List all markdown files (`*.md`) inside `.jai/conversations/` and `.jai/plans/`.
4. For each file found, read its content to extract the `**Summary**:` section (typically in the first few lines).
5. Present the list of files categorized under two distinct sections:
    - **Active Plans** (files from `.jai/plans/`)
    - **Recent Conversations** (files from `.jai/conversations/`)
    Include the filename and its summary for each.
6. If the user or context implies a specific topic, recommend the most relevant file from either category.
7. Once the correct file is identified, read its full content to load the context.

