---
name: verify-plan-assumptions
description: Audits a spec, plan, or PRD by spawning a subagent to cross-reference it with the live codebase, identifying mismatches in APIs, schemas, configurations, and file structures.
---

# Verify Plan Assumptions

Use this skill when you or the user have proposed a spec, plan, or PRD, and you want to verify that the implementation plan aligns with the actual, current state of the codebase.

## Workflow

1. **Identify the Plan/Spec**:
   - Locate the target plan, spec, or design document (typically in `.jai/plans/` or `.jai/tmp/`).

2. **Spawn the Verification Subagent**:
   - Launch a specialized `research` or `self` subagent.
   - **CRITICAL**: The prompt to the subagent must be goal-oriented. Do not prescribe specific files to read or commands to run. Instead, define the objective and constraints.
   - **Goal-Oriented Prompt Template**:
     ```
     You are verifying a spec/plan against the live codebase: <PLAN_PATH>
     
     Identify and report:
     1. Stale or incorrect assumptions about existing APIs, function signatures, data schemas, and exports.
     2. Mismatches in configuration structures, file layouts, or environment variables.
     3. Hidden dependencies or API prerequisites that are omitted from the plan.
     
     Constraints:
     - Do not make or suggest changes to the codebase.
     - Rely only on live codebase verification (do not guess).
     - Focus on technical blocking issues that would make the plan unbuildable or break existing flows.
     ```

3. **Integrate Findings**:
   - Once the subagent reports back, summarize the findings (specifically flagging critical vs. minor assumption mismatches).
   - Update the spec or plan directly to correct these assumptions, or present the findings to the user for guidance.
