---
name: writing-skills
description: Use when creating new skills or editing existing skills in the gemini/skills directory
---

# Writing Skills

## Overview
Writing skills is Test-Driven Development (TDD) applied to instructions and workflows.

## Rules for Skill Files

1. **Triggering Description (YAML)**:
   - Use `name` with hyphens (no special characters).
   - The `description` field MUST start with "Use when..." and focus ONLY on the triggering conditions and symptoms.
   - **CRITICAL**: Do NOT summarize the skill's workflow/process in the description. Otherwise, the agent will skip reading the full skill.

2. **Structure**:
   - Keep it concise (aim for <300 words).
   - Use headings: Overview, When to Use, Core Pattern, and Common Mistakes.
   - Cross-reference other files instead of duplicating.

3. **TDD Workflow**:
   - Identify a common agent mistake.
   - Run a test task/subagent to observe the mistake (RED).
   - Write the minimal skill guidance to fix it (GREEN).
   - Verify the agent now follows it correctly.
