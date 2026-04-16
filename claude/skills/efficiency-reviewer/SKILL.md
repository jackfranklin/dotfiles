---
name: efficiency-reviewer
description: Reviews code changes for efficiency issues, unnecessary work, missed concurrency, and memory leaks. Use when the user asks to "review for efficiency", "check for performance issues", "find memory leaks", or wants an efficiency-focused code review.
---

# Efficiency Reviewer

## Step 1: Identify target

Determine what code to review:
- Default to uncommitted changes (`git diff` and `git diff --cached`)
- If the user specified a file or range, use that
- If unclear, ask before proceeding

## Step 2: Review

Spawn an Explore subagent via the Agent tool. Give it the diff/file contents, the repo root path, and these instructions:

Review the changes for efficiency issues. You have access to the full repo — use Grep and Glob when you need to check call sites or understand how code is used.

1. Unnecessary work: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. Missed concurrency: independent operations run sequentially when they could run in parallel
3. Hot-path bloat: new blocking work added to startup or per-request/per-render hot paths
4. Unnecessary existence checks: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
5. Memory: unbounded data structures, missing cleanup, event listener leaks
6. Overly broad operations: reading entire files when only a portion is needed, loading all items when filtering for one

## Step 3: Report findings

Present findings as a list. For each finding include:
- File path and line number
- What the issue is
- Concrete suggestion for how to fix it

Do not make any changes. If the user asks to fix specific items, apply those fixes directly.
