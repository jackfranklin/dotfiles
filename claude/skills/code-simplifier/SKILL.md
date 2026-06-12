---
name: code-simplifier
description: Runs the Code Simplifier subagents (Code Reuse Reviewer, Code Quality Reviewer, and Efficiency Reviewer) to review and clean up code changes. Trigger this skill when the user asks to "simplify code", "run code simplifier", or "review changes for quality".
---

# Code Simplifier Skill

When triggered, perform the following steps to execute a code simplification review:

1. **Identify Target**: Determine the specific code changes to review based on the user's request (e.g., a specific file, uncommitted changes, or a git diff). Ask them to specify what to review if they haven't already.
2. **Parallel Invocation**: Invoke all three agents (`code_reuse_reviewer`, `code_quality_reviewer`, `efficiency_reviewer`) in parallel using their respective tools. Pass each agent the full context or diff of the changes to review.
3. **Aggregation and Fix**: Wait for all three agents to complete. Aggregate their findings and fix each issue directly. If a finding is a false positive or not worth addressing, note it and move on.
