---
name: bug-report
description: Use when the user requests to turn the current conversation, exploration, or technical findings into a succinct bug report.
---

# Bug Report

## Overview
Compiles a technical exploration or conversation into a clear, minimal, and actionable bug report.

## When to Use
- When a bug has been identified or explored in the conversation, and the user wants to document it as a bug report.
- When the user asks to "write a bug report" or "create a bug report from this".

## Core Pattern
1. Extract the core issue from the exploration or conversation history.
2. Structure the bug report as follows:
   - **Title**: A clear, concise title summarizing the bug.
   - **Problem Statement**: What is the bug? (1-2 sentences).
   - **Why It Matters**: The impact of the bug or why it should be fixed (1-2 sentences).
   - **Steps to Reproduce (if known/applicable)**: A clear, minimal numbered list of steps.
   - **Expected Behavior**: What should have happened.
   - **Actual Behavior**: What actually happened.
3. Exclude any details about specific fixes, pull requests, list of affected files, code diffs, or implementation details.
4. Present the bug report directly as a response in the conversation. Do not write the report to disk or save it to any file.
5. Keep the report extremely focused and clear.

## Common Mistakes
- Writing the bug report to a file on disk or creating an artifact.
- Including code diffs or proposed fixes in the report.
- Listing files to modify or technical details of the fix.
- Writing long paragraphs instead of punchy, scannable statements.
