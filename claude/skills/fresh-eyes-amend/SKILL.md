---
name: fresh-eyes-amend
description: Amends the previous commit with current changes, then spawns two subagents to independently review the full git diff and propose fresh commit messages. Synthesizes the best parts into a final, accurate commit message without recency bias.
---

# Fresh Eyes Amend

Use this skill when you want to amend the previous commit and ensure the commit message accurately and unbiasedly reflects the entire combined change.

## Workflow

1.  **Check Status and Stage Changes**: Run `git status --porcelain` to check for active, unstaged changes. If and only if there are changes to be staged, stage them using appropriate `git add` commands (e.g., `git add -u` or `git add <file>`). Avoid blindly running `git add -A` unless you intend to include all modified and untracked files in the commit. If there are no changes to stage, proceed to the next step.

2.  **Capture Old Message**: Retrieve and save the current commit message:
    ```bash
    git log -1 --pretty=%B
    ```
    Keep this as `OLD_MESSAGE`.

3.  **Capture Full Diff**: Get the complete diff of the staged changes (and current `HEAD`) against the parent of `HEAD`:
    ```bash
    git diff --cached HEAD~1
    ```
    Keep this as `FULL_DIFF`.

4.  **Spawn Subagents with Zero Context**:
    Invoke **two** parallel subagents using the `invoke_subagent` tool. Both subagents must receive the identical `FULL_DIFF` and be instructed to evaluate it with zero prior context.

    *   **Subagent 1** (`FreshEyesReviewer1`):
        *   **Role**: Fresh Eyes Reviewer A
        *   **Prompt**:
            ```
            You are a fresh-eyes code reviewer. Your only source of information is the git diff provided below. Do not use any other tools to explore the codebase or check git history. Write a high-quality commit message (following standard guidelines: imperative mood, clear summary, explanation of "why" and "how" in the body) that accurately and completely summarizes the changes in this diff. Do not assume any context outside of what is visible in the diff.

            CRITICAL: Do NOT include trivial, inane, or self-evident details in the message body (e.g., "added unit tests", "fixed lint errors", "updated imports", "formatted code", "updated build files"). Focus exclusively on the logical "why" and "how" of the change.

            Diff:
            <FULL_DIFF>
            ```
    *   **Subagent 2** (`FreshEyesReviewer2`):
        *   **Role**: Fresh Eyes Reviewer B
        *   **Prompt**: Use the exact same prompt as Subagent 1.

5.  **Synthesize Message**:
    - Wait for both subagents to return their suggested commit messages.
    - Compare `OLD_MESSAGE`, the two new proposals, and `FULL_DIFF`.
    - Synthesize the best parts of the proposals to create a single final commit message that accurately reflects the entire combined change.
    - CRITICAL: Ensure the synthesized commit message NEVER includes trivial, inane, or self-evident details in the body (e.g., "added unit tests", "fixed lint errors", "updated imports", "formatted code", "updated build files"). Focus exclusively on the logical "why" and "how" of the change.

6.  **Propose Message to User**: Present the synthesized commit message to the user for approval. Do not apply it to the commit automatically.

7.  **Apply Approved Message**:
    Once the user approves the message (or provides revisions), apply it and amend the commit:
    ```bash
    git commit --amend -m "<APPROVED_MESSAGE>"
    ```

8.  **Report**: Confirm to the user that the amend is complete.
