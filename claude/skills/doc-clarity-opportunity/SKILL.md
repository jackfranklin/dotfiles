---
disable-model-invocation: true
name: doc-clarity-opportunity
description: Looks for opportunities to improve documentation and code clarity — JSDoc, inline comments, and README updates. Use when the user wants to find documentation gaps or improve code clarity.
---

# Doc Clarity Opportunity Skill

## 1. Identify Target Scope
Determine which files or changes to analyze (e.g., current workspace changes, specific files, or a git diff). If the scope is ambiguous, ask the user for clarification.

## 2. Review for Clarity Opportunities

Analyze the target scope directly. Look for three types of improvements:

- **JSDoc / type comments**: exported functions, classes, or types with non-obvious signatures that lack documentation
- **Inline comments**: complex logic, non-obvious invariants, workarounds, or hidden constraints with no explanation
- **README / docs**: stale information, missing setup steps, undocumented behaviours visible in the code

**High bar**: only flag improvements that add net-new context — rationale, invariants, workarounds, or side effects a reader wouldn't derive from reading the code. Discard suggestions for obvious or self-documenting code.

## 3. Present Suggestions & Await Approval
Present the filtered list of high-value documentation improvements to the user. Do NOT apply any changes directly — await explicit approval before proceeding.
