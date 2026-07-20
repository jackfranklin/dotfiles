---
disable-model-invocation: true
name: code-walkthrough
description: Walk the developer through the implemented code changes (diff) step-by-step in the chat interface, explaining each part and pausing for questions.
---

# Code Walkthrough

Use this skill when the developer wants to review and understand a set of code changes (either a draft diff in the workspace or a recently committed change) step-by-step.

The goal is to explain the "why" and "how" of the changes progressively, giving the developer space to ask questions or suggest modifications for each part before moving on.

## Steps

### 1. Identify the Changes

Locate the diff to walk through:

- For uncommitted changes: use `git diff HEAD` (or similar).
- For a recent commit: use `git show <commit-hash>` or `git diff HEAD~1 HEAD`.
- If the changes are already discussed in the context, use the context.
- If you are unsure, ask the user for confirmation.

### 2. Group into Logical Steps

Group the changes into logical steps to avoid overwhelming the developer.

- Group by file or by logical feature if changes are spread across files. Think about presenting the steps in chronological order to represent how the feature/fix was built out.
- Keep track of the current step index (e.g., "Step 1 of 3").

### 3. Progressive Walkthrough

For each logical group of changes:

1.  **Present the Change:**
    - State the file path and what part of the code is changing.
    - Show the relevant diff snippet or code block.
2.  **Explain the Logic:**
    - Explain **why** this change was made (the bug it fixes or the feature it implements).
    - Explain **how** it works (the mechanism of the change).
    - Keep the explanation concise and direct (adhere to "No Bullshit" guidelines).
3.  **Pause for Questions:**
    - Ask the developer if they have any questions or if they are ready to move to the next step.
    - End your turn and wait for the developer's response.

### 4. Handle Feedback

- If the developer has questions:
  - Answer them directly and clearly.
  - Wait for their confirmation before moving on.
- If the developer suggests changes:
  - Discuss the changes and implement them if agreed.
  - Re-explain the updated change and ask for approval again.
- If the developer says they are ready:
  - Proceed to the next step.

### 5. Wrap Up

Once all steps are completed:

- Briefly summarize the overall change.
- Ask if there are any final questions or next steps.
