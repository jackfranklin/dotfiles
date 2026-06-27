---
disable-model-invocation: true
name: doc-clarity-opportunity
description: Looks for opportunities to improve documentation and code clarity by spawning specialized subagents for JSDoc, inline comments, and README updates, then synthesizing their findings for user review and approval.
---

# Doc Clarity Opportunity Skill

When identifying opportunities to improve codebase documentation and clarity, follow this workflow:

## 1. Identify Target Scope
Determine which files or changes to analyze (e.g., current workspace changes, specific files, or a git diff). If the scope is ambiguous, ask the user for clarification.

## 2. Spawn Specialized Subagents
Invoke the following specialized review agents concurrently via the `invoke_subagent` tool to analyze the target scope:
- `doc_clarity_jsdoc_reviewer`
- `doc_clarity_inline_comment_reviewer`
- `doc_clarity_readme_reviewer`

Pass each agent the relevant code context or diff.

## 3. Aggregate and Filter Findings
Wait for all subagents to complete their analysis. Gather and critically synthesize all suggested opportunities.
**CRITICAL FILTERING**:
- Filter out any suggestions that recommend low-value, descriptive, plain-English comments for obvious or self-documenting code.
- Maintain a high bar. If a subagent suggests a comment that does not provide net-new context (such as rationale, invariants, workarounds, or hidden side effects), reject and discard it.
- Compile only the highly necessary documentation improvements (e.g. for JSDoc, inline comments, or README files).

## 4. Present Suggestions & Await Approval
Present the filtered list of high-value documentation and clarity improvements to the user.
**CRITICAL**: Do NOT apply any changes directly. State your plan based on these suggestions and await the user's explicit approval before proceeding with any implementation.
