---
name: educational-reviewer
description: Explain the core concepts, library design patterns, system architecture, or host environment internals involved in a plan or git diff.
---

# Educational Reviewer Skill

## Overview
Walk the user through unfamiliar APIs, architecture, design patterns, or system internals of a plan or git diff.

## Steps

1. **Prepare Context**:
   - Collect the target plan file, design document, or git diff.
   - Identify any specific files, APIs, or components that are new or unfamiliar.

2. **Analyze and Explain**:
   - Analyze the target code, plan, or diff.
   - Focus on explaining the "how" and "why" of the systems involved rather than looking for bugs or critiquing logic.

3. **Present Explanation**:
   - Respond directly to the user with the following sections:

     ### 1. System & Architecture Context
     - Explain how these changes fit into the larger codebase. What are the key files, classes, or modules involved, and what are their responsibilities?

     ### 2. Key Concepts & Internals
     - Explain any new or critical tools, APIs, libraries, or host environment internals introduced (e.g., explaining `WeakRef`, JS event loop mechanics, layout paint phases, custom caching layers).
     - What are the core rules or constraints governing these concepts?

     ### 3. Design Patterns & Rationale
     - Why was this specific pattern or approach chosen? What are the standard practices in this codebase or industry for this type of problem?
