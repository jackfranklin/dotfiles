---
name: code-reuse-reviewer
description: Reviews code changes to identify opportunities for reusing existing utilities and helpers. Use when the user asks to "review for reuse", "check for duplicate code", "find existing utilities", or wants a reuse-focused code review.
---

# Code Reuse Reviewer

## Step 1: Identify target

Determine what code to review:
- Default to uncommitted changes (`git diff` and `git diff --cached`)
- If the user specified a file or range, use that
- If unclear, ask before proceeding

## Step 2: Review

Spawn an Explore subagent via the Agent tool. Give it the diff/file contents, the repo root path, and these instructions:

Review the changes for code reuse opportunities. You have access to the full repo — use Grep and Glob to search it.

1. Search for existing utilities and helpers that could replace newly written code. Use Grep to find similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. Flag any new function that duplicates existing functionality. Suggest the existing function to use instead.
3. Flag any inline logic that could use an existing utility — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

## Step 3: Report findings

Present findings as a list. For each finding include:
- File path and line number
- What the issue is
- Concrete suggestion (e.g. the existing function/utility to use instead)

Do not make any changes. If the user asks to fix specific items, apply those fixes directly.
