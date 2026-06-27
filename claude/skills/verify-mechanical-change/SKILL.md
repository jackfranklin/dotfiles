---
disable-model-invocation: true
name: verify-mechanical-change
description: Spawns two independent subagents to verify if the staged or specified git diff is purely mechanical (no behavior or UI changes), then synthesizes their findings to ensure high accuracy.
---

# Verify Mechanical Change Skill

Use this skill when the user wants to confirm that a change is purely mechanical and contains no changes to behavior, UI, or application logic.

## Workflow

1.  **Retrieve the Git Diff**:
    Identify the diff to analyze. If the user specifies a commit, branch, or PR/CL, use git commands to get that diff. Otherwise, get the unstaged and staged changes in the workspace:
    - Get staged changes: `git diff --cached`
    - Get unstaged changes: `git diff`
    - Combine them or ask the user if they want to analyze staged, unstaged, or both.
    Save this diff as `DIFF_CONTENT`.
    
    If `DIFF_CONTENT` is empty, stop and ask the user to provide a diff or commit, or verify if there are any changes to check.

2.  **Invoke Two Parallel Subagents**:
    Invoke **two** parallel subagents using the `invoke_subagent` tool with `TypeName: research` (to ensure they have read-only tools to explore the codebase for tracing symbol usage/definitions).
    
    Pass the identical prompt and `DIFF_CONTENT` to both.

    *   **Subagent 1** (`MechanicalChangeReviewer1`):
        *   **Role**: Mechanical Change Reviewer A
        *   **Prompt**:
            ```
            You are an expert code reviewer. Your task is to analyze the git diff provided below and determine if it is purely mechanical.
            
            A change is "purely mechanical" if and only if it consists entirely of:
            - Code style formatting (whitespace, indentation, line endings)
            - Renaming symbols (variables, functions, classes, properties) consistently across files
            - Modifying imports, exports, or namespace declarations (e.g. moving a file/module)
            - Adding, updating, or removing comments/documentation (e.g. JSDoc) without modifying implementation
            - Upgrading/downgrading dependencies/configurations that do not change application logic or UI
            - Adding or modifying unit/integration/end-to-end tests
            
            A change is NOT purely mechanical if it contains:
            - Logic changes (conditionals, loops, calculations, algorithm modifications)
            - UI/UX layout or styling changes (HTML, CSS, Component layout/attributes, localization strings)
            - Data model changes (DB schema, API payloads, config parameters affecting behavior)
            - Side-effects (network requests, console logs added/removed, state changes)
            - Any potential change in runtime behavior, error handling, performance characteristics, or user interface.
            
            Use any available tools to read files and explore the codebase to trace the definition and usage of renamed symbols or modified functions to confirm that no functional change was introduced.
            
            CRITICAL GUIDELINES:
            - Do NOT run any tests. Assume that all existing tests pass.
            - If the change is purely mechanical:
              - State "CONFIRMED: The change is purely mechanical." and explain why.
              - Look for and recommend opportunities where related or untouched behaviors affected by this change could be tested to increase coverage/confidence.
            - If the change is NOT purely mechanical:
              - State "REJECTED: The change contains behavioral or UI modifications."
              - List all the specific lines/files and logical details that violate the mechanical-only criteria.
              - Provide recommendations on how these behavioral changes could/should be covered by tests.
            
            Diff:
            <DIFF_CONTENT>
            ```
            
    *   **Subagent 2** (`MechanicalChangeReviewer2`):
        *   **Role**: Mechanical Change Reviewer B
        *   **Prompt**: Use the exact same prompt as Subagent 1.

3.  **Synthesize Findings**:
    - Wait for both subagents to return their findings.
    - Compare their reports.
    - If BOTH confirm the change is purely mechanical:
      - Report: "Both subagents confirmed the change is purely mechanical." and briefly summarize the rationale.
      - Synthesize and present the recommended testing opportunities for untouched/related behaviors.
    - If EITHER rejects or finds a behavioral change:
      - Report: "The change might NOT be purely mechanical."
      - Detail the specific concerns, line numbers, and file names raised by the subagents.
      - Summarize the potential behavioral or UI differences discovered.
      - Synthesize and present the recommendations on how to test these behavioral changes.
    - Present the synthesized findings clearly to the user.
