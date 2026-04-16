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

Spawn an Explore subagent via the Agent tool with the diff/file contents and the following instructions:

Review the changes for code reuse opportunities:

1. Search for existing utilities and helpers that could replace newly written code. Use grep/glob to find similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. Flag any new function that duplicates existing functionality. Suggest the existing function to use instead.
3. Flag any inline logic that could use an existing utility — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

## Step 3: Report and fix

Present findings to the user. If they ask to fix, apply each fix directly. Skip false positives without arguing — just note and move on.
