---
disable-model-invocation: true
name: suggest-manual-tests
description: Use when the user wants to generate manual test cases, QA steps, or test plans based on a git diff of latest commits, branch comparison, or unstaged changes.
---

# Suggest Manual Tests Skill

Use this skill when the user requests manual test cases or QA verification steps to test recent changes.

## Workflow

1.  **Retrieve the Git Diff**:
    Ask the user which git diff they would like to use:
    -   1. **Unstaged changes** (`git diff`)
    -   2. **Staged changes** (`git diff --cached`)
    -   3. **Branch comparison vs origin/main** (`git diff origin/main...`)
    -   4. **Latest commit** (`git diff HEAD~1`)
    -   5. **Custom range** (e.g., specific commits or branch)
    
    If the user has already specified which diff to use, skip the question and retrieve the diff using the corresponding `git` command.
    Save the output as `DIFF_CONTENT`.
    
    If the diff is empty, notify the user and ask them to make changes or provide a valid ref.

2.  **Analyze the Diff**:
    Analyze the files and code modified in `DIFF_CONTENT`. For each modified component, function, endpoint, or page, identify:
    -   **Logical behavior**: What changed?
    -   **User interface**: Are there styling or interactive changes?
    -   **Side-effects**: Does it change state, call APIs, send analytics, read/write storage?
    -   **Dependencies**: What other parts of the system consume this modified code?

3.  **Generate Manual Test Cases**:
    Create a structured, succinct list of manual test cases. For each logical/functional change, provide:
    
    -   **Test Case ID & Title**: Short, clear name (e.g., `TC01: Verify Form Validation on Error`).
    -   **Scope**: What specific bug, feature, or code change is being verified.
    -   **Prerequisites / Setup**: Any local database, env variable, config change, mock data, or state required before starting.
    -   **High-Level Steps**: Concise instructions. Do NOT detail menial UI clicks (e.g. "click button X and then click Y"). Assume the developer/tester knows how to operate the application/tool.
    -   **Expected Result**: Clear description of what should happen (visual verification, console logs, network requests, database changes).

    *Guidelines*:
    - **Keep it succinct**: Focus on manual-specific verification that automated tests might not cover well (e.g. UI layout, accessibility, interactions, complex flows).
    - **Offer edge cases**: If there are many manual edge cases, present the core cases first and explicitly ask the user if they want the full set of edge cases.

4.  **Present Results**:
    Present the generated manual test cases directly inline in the chat. Do NOT save them to a file or write them to disk.

## Examples

Refer to [sample-test-plan.md](file:///Users/jacktfranklin/dotfiles/nvim/lua/upstream-dotfiles/claude/skills/suggest-manual-tests/examples/sample-test-plan.md) for a reference implementation of high-level manual testing scenarios.
