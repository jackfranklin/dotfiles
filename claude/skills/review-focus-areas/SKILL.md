---
name: review-focus-areas
description: Identify and flag key areas of concern, plan deviations, risky changes, and uncertainties for the user to review.
---

# Review Focus Areas Skill

Use this skill when you have completed an implementation and want to prepare a guided review for the user. This skill generates a structured report flagging high-value review points while filtering out menial or uncontroversial changes.

## Steps

1. **Collect Context**:
   - Determine the target branch (e.g. `origin/main`, `master`, or `HEAD~1` if on a single-commit branch).
   - Generate the diff: `git diff <target-branch>...HEAD` or similar.
   - Retrieve the original implementation plan, goals, or requirements from the conversation transcript or active task context.

2. **Invoke Subagent**:
   - Invoke the `self` subagent with the role `Fresh Eyes Reviewer` to analyze the changes independently.
   - Provide the subagent with the git diff and the original plan.
   - Prompt the subagent to identify:
     1. **Plan Deviations / Hiccups**: Where the implementation deviated from the plan, or where unexpected technical hurdles were encountered.
     2. **Risky Changes**: Complex logic, state management, potential concurrency/race conditions, error handling gaps, or resource lifecycle issues.
     3. **Uncertainties**: Areas where a second opinion or human validation is needed.
     4. **Other Key Areas**: Anything else that warrants close human attention.
   - Explicitly instruct the subagent to **exclude** menial changes (imports, formatting, simple renames, boilerplate).

3. **Format Output**:
   - The subagent should structure the output as a Markdown list of focus areas.
   - For each focus area:
     - **File**: Path to the file, formatted as a clickable link (e.g. `[filename](file:///absolute/path/to/file#L123-L145)`).
     - **Type**: One of `Deviation`, `Risk`, `Uncertainty`, or `Attention`.
     - **Explanation**: Concise explanation of the change, the reasoning behind it, and why it is flagged.
     - **Code Snippet**: Fenced code block showing the relevant changed or added code.

4. **Write Artifact**:
   - Save the formatted output to a new markdown artifact file named `review_focus_areas.md` in the conversation artifact directory (`<appDataDir>/brain/<conversation-id>/`).
   - Present a link to this artifact to the user, highlighting key open questions or decisions.
