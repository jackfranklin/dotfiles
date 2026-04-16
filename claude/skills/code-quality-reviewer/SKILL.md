---
name: code-quality-reviewer
description: Reviews code changes for hacky patterns, redundant state, parameter sprawl, and leaky abstractions. Use when the user asks to "review code quality", "check for hacky patterns", "quality review", or wants a quality-focused code review.
---

# Code Quality Reviewer

## Step 1: Identify target

Determine what code to review:
- Default to uncommitted changes (`git diff` and `git diff --cached`)
- If the user specified a file or range, use that
- If unclear, ask before proceeding

## Step 2: Review

Spawn an Explore subagent via the Agent tool. Give it the diff/file contents, the repo root path, and these instructions:

Review the changes for hacky patterns. You have access to the full repo — use Grep and Glob when you need to check how existing patterns are used elsewhere.

1. Redundant state: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. Parameter sprawl: adding new parameters to a function instead of generalizing or restructuring existing ones
3. Copy-paste with slight variation: near-duplicate code blocks that should be unified with a shared abstraction
4. Leaky abstractions: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. Stringly-typed code: using raw strings where constants, enums (string unions), or branded types already exist in the codebase

## Step 3: Report findings

Present findings as a list. For each finding include:
- File path and line number
- What the issue is
- Concrete suggestion for how to fix it

Do not make any changes. If the user asks to fix specific items, apply those fixes directly.
