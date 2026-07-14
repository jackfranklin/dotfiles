---
name: educational-reviewer
description: Explain the core concepts, library design patterns, system architecture, or host environment internals involved in a plan or git diff. Spawns an isolated subagent to perform the education.
---

# Educational Reviewer Skill

## Overview
Walk the user through unfamiliar APIs, architecture, design patterns, or system internals of a plan or git diff. This skill runs in an isolated subagent to ensure no context pollution.

## Steps

1. **Prepare Context**:
   - Collect the target plan file, design document, or git diff.
   - Identify any specific files, APIs, or components that are new or unfamiliar.

2. **Invoke Subagent**:
   - Invoke the `educational_reviewer` subagent using the `invoke_subagent` tool.
   - Pass the plan/diff and ask the subagent to explain the key concepts and architecture involved.

3. **Present Explanation**:
   - Once the subagent responds, present its explanation directly to the user.
