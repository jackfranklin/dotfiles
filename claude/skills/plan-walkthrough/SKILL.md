---
disable-model-invocation: true
name: plan-walkthrough
description: >
  Walk the developer through an implementation plan step-by-step in the chat interface.
  Explains the rationale, non-trivial alternatives considered, and risks for each step
  before pausing for feedback or approval.
---

# Plan Walkthrough

Use this skill when the developer wants to review a proposed implementation plan (either saved as a GitHub Issue or draft plan in the current conversation context) step-by-step before beginning execution.

The goal is to explain the rationale, trade-offs, and critical decisions of the plan to the developer progressively, rather than presenting the entire plan to read in one go.

## Steps

### 1. Locate the Plan

Identify the plan to walk through:
- If a plan is already saved as a GitHub Issue, fetch it: `gh issue view <number> --json title,body`.
- If a plan is only present in the current conversation context (e.g. drafted in previous messages), use the draft plan.
- If you are unclear which plan to use, do not assume. Ask for clarification.

### 2. Prepare the Walkthrough State

Identify all the individual steps/tasks in the plan.
- Keep track of the current step index (e.g., "Step 1 of 5").
- Maintain a list of any changes or feedback requested by the developer during the walkthrough.

### 3. Progressive Step Walkthrough

For each step in the plan:

1. **Present the Step details**:
   - Step/Task title, target files to create/modify/test.
   - A brief summary of what this step implements.

2. **Explain the Rationale (Dynamic & Adaptive)**:
   - Explain *why* you chose this approach. What is the core design decision?
   - **Alternatives Considered**: If there were non-trivial alternative approaches, explain what they were and why they were rejected. (Skip if trivial).
   - **Risks/Assumptions**: Identify any potential issues, dependencies, or assumptions that need verification. (Skip if none).
   - Keep the explanation concise and focused, avoiding conversational fluff.

3. **Pause for Feedback**:
   - Ask the developer if they approve this step or if they have any questions or feedback.
   - End your turn and wait for the developer's response.

### 4. Handle Feedback & Updates

- **If the developer asks questions or has concerns**:
  - Address their questions directly.
  - If they suggest changes to the step, discuss the impact of those changes.
  - Once changes are agreed upon, update your internal draft of the plan.
  - Re-explain the updated step (if necessary) and ask for approval again.
- **If the developer approves**:
  - Proceed to the next step.

### 5. Finalize the Plan

Once all steps have been walked through and approved:
- If the plan was only in the conversation context (drafted in chat), create a new GitHub Issue:
  ```bash
  gh issue create --title "[PLAN] <feature-name>" --body "<full plan content>"
  ```
  And tell the developer the created issue URL.
- Summarize the final plan very briefly and ask if the developer is ready to start the implementation.
