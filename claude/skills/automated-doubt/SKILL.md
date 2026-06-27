---
disable-model-invocation: true
name: automated-doubt
description: Runs a pipeline of specialized validator subagents post-implementation to audit the code from various critical perspectives (Scope, Type Safety, Security, Accessibility, Localization, Resource Management, Anxiety/Concurrency, and Public Interfaces).
---

# Automated Doubt Skill

Use this skill after completing code changes, prior to committing or shipping, to perform a rigorous multi-perspective audit.

## Workflow

1. **Determine the Scope of the Change**:
   - Check if you are on a feature branch or have staged/unstaged changes.
   - Identify the list of modified/added files and affected lines (e.g., using `git diff --name-only` or comparing against the base branch).
   - Use this set of touched files and lines to define the target scope for the audit.

2. **Invoke Auditor Subagents Concurrently**:
   - Spawn multiple specialized `research` or `self` subagents in parallel using the `invoke_subagent` tool.
   - **CRITICAL**: The prompts must be goal-oriented, specifying the objective and constraints, leaving the subagents to decide how to analyze the codebase.
   - **Scope Constraint**: Instruct the subagents to focus their validation and report findings *only* for code within the determined scope of modified/added files and lines, ignoring pre-existing issues in untouched files or code blocks.

   *   **Type Safety Validator**:
       - **Objective**: Audit the new/modified code for strict type safety.
       - **Constraints**: Specifically look for loose typings (`any`), excessive casting, and forbidden type overrides (like `as any`).

   *   **Accessibility (a11y) Analyst**:
       - **Objective**: Inspect UI changes for accessibility compliance.
       - **Constraints**: Verify correct semantic HTML, keyboard operability (focus states), and presence of necessary ARIA attributes.

   *   **Localization (i18n) Validator**:
       - **Objective**: Ensure all user-facing strings are localizable.
       - **Constraints**: Verify that all new UI strings are declared using the codebase's standard localization patterns, avoiding hardcoded raw string literals in user-facing UI elements.

   *   **Resource Management Auditor**:
       - **Objective**: Identify potential memory or resource leaks.
       - **Constraints**: Check that timers (`setTimeout`/`setInterval`) and event subscriptions/listeners are properly cleaned up in the UI component or system lifecycle (e.g., component unmount, disconnect, or disposal hook).

   *   **Security Analyst**:
       - **Objective**: Inspect the changes for potential security liabilities.
       - **Constraints**: Audit for unsanitized inputs, path traversal, injection vectors, and accidental leakage of sensitive environment variables or filesystem paths in logs/errors.

   *   **Anxiety Reader**:
       - **Objective**: Identify what could go wrong under stress, load, or race conditions.
       - **Constraints**: Look for concurrent API hits without limit, race conditions, resource/memory leaks, unhandled promise rejections, and missing rate limit handling.

   *   **Public Interface Validator**:
       - **Objective**: Review modifications to exported APIs, types, or interfaces.
       - **Constraints**: Verify compatibility, proper encapsulation, and check if change introduces breaking API contracts.

3. **Consolidate and Address Findings**:
   - Wait for all subagents to finish.
   - Summarize findings into a structured format (categorized by severity: Critical, High, Medium, Low).
   - Address the findings iteratively, re-running the automated doubt validators until quality standards are met.
