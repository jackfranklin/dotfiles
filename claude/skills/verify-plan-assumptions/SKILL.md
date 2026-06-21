---
name: verify-plan-assumptions
description: Audits a spec, plan, or PRD by spawning a subagent to cross-reference it with the live codebase, identifying mismatches in APIs, schemas, configurations, and file structures.
---

# Verify Plan Assumptions

Use this skill when you have a spec, plan, or PRD and want to verify it
aligns with the actual current state of the codebase before investing in
detailed planning or implementation.

## Workflow

1. **Identify the Plan/Spec**:
   - Locate the target plan, spec, or design document (typically in `.jai/plans/` or `.jai/tmp/`).

2. **Spawn the Verification Subagent**:
   - Launch a specialized `research` or `self` subagent.
   - **CRITICAL**: The prompt must be goal-oriented. Do not prescribe specific files to read or commands to run. Define the objective and constraints.
   - **Goal-Oriented Prompt Template**:
     ```
     You are verifying a spec/plan against the live codebase: <PLAN_PATH>

     Identify and report:
     1. Stale or incorrect assumptions about existing APIs, function signatures, data schemas, and exports.
     2. Mismatches in configuration structures, file layouts, or environment variables.
     3. Hidden dependencies or API prerequisites omitted from the plan.

     Constraints:
     - Do not make or suggest changes to the codebase.
     - Rely only on live codebase verification — do not guess.
     - Focus on technical blocking issues that would make the plan unbuildable or break existing flows.
     ```

3. **Integrate Findings**:
   - Once the subagent reports back, summarize findings flagging critical vs. minor mismatches.
   - Update the spec or plan to correct assumptions, or present findings to the user for guidance.
