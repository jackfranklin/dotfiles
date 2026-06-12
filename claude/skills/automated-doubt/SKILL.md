---
name: automated-doubt
description: Runs a pipeline of specialized validator subagents post-implementation to audit the code from various critical perspectives (Type Safety, Security, Anxiety/Concurrency, and Public Interfaces).
---

# Automated Doubt Skill

Use this skill after completing code changes, prior to committing or shipping, to perform a rigorous multi-perspective audit.

## Workflow

1. **Invoke Auditor Subagents Concurrently**:
   - Spawn multiple specialized `research` or `self` subagents in parallel using the `invoke_subagent` tool.
   - **CRITICAL**: The prompts must be goal-oriented, specifying the objective and constraints, leaving the subagents to decide how to analyze the codebase.

   *   **Type Safety Validator**:
       - **Objective**: Audit the new/modified code for strict type safety.
       - **Constraints**: Specifically look for loose typings, excessive casting, and forbidden `as any` expressions (violating user rules).
       
   *   **Security Analyst**:
       - **Objective**: Inspect the changes for potential security liabilities.
       - **Constraints**: Audit for unsanitized inputs, path traversal, injection vectors, and accidental leakage of sensitive environment variables or filesystem paths in logs/errors.
       
   *   **Anxiety Reader**:
       - **Objective**: Identify what could go wrong under stress, load, or race conditions.
       - **Constraints**: Look for concurrent API hits without limit, race conditions, resource/memory leaks, unhandled promise rejections, and missing rate limit handling.
       
   *   **Public Interface Validator**:
       - **Objective**: Review modifications to exported APIs, types, or interfaces.
       - **Constraints**: Verify compatibility, proper encapsulation, and check if change introduces breaking API contracts.

2. **Consolidate and Address Findings**:
   - Wait for all subagents to finish.
   - Summarize findings into a structured format (categorized by severity: Critical, High, Medium, Low).
   - Address the findings iteratively, re-running the automated doubt validators until quality standards are met.
