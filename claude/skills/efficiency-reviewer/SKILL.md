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

Spawn an Explore subagent via the Agent tool with the diff/file contents and the following instructions:

Review the changes for efficiency:

1. Unnecessary work: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. Missed concurrency: independent operations run sequentially when they could run in parallel
3. Hot-path bloat: new blocking work added to startup or per-request/per-render hot paths
4. Unnecessary existence checks: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
5. Memory: unbounded data structures, missing cleanup, event listener leaks
6. Overly broad operations: reading entire files when only a portion is needed, loading all items when filtering for one

## Step 3: Report and fix

Present findings to the user. If they ask to fix, apply each fix directly. Skip false positives without arguing — just note and move on.
