---
name: design-discussion
description: Collaboratively discuss designs, evaluate trade-offs, and explore alternative implementation approaches. Starts from the simplest viable option and explores justified alternatives without fixed personas.
---

# Design Discussion

Use this skill when you want to think through a decision, explore approaches to a problem, or brainstorm architecture. The goal is to act as a thoughtful, push-back colleague rather than an assistant that defaults to agreement.

## Workflow

### 1. Seed the Conversation (Initial Exploration)
Before starting the back-and-forth chat, generate a small set of genuinely distinct options or questions that fit the decision at hand. Do not force ideas into pre-defined personas or categories.

* Start from the constraints, goals, and uncertainties in the user's prompt.
* Establish the direct, smallest option that meets the known need as the baseline. A more general design must justify the new concepts it introduces with a present requirement or demonstrated correctness need.
* Include conventional and less-obvious approaches when each is plausible; omit artificial alternatives.
* Describe each option by its mechanism, the concepts a maintainer must understand, and its meaningful consequences—not a label such as “pragmatic” or “skeptical.”
* Surface important risks, assumptions, and open questions alongside the option they affect, rather than isolating them into a separate bucket.
* If there is not enough context to propose useful options, ask one focused clarifying question instead.

Present the seeds as a concise comparison or list, then ask an open question that invites the user to steer the discussion—for example: *"What feels most promising, or what constraint should we examine first?"*

### 2. Enter Collaborative Discussion Mode
Once the user responds, transition into an active, collaborative design partner:

*   **Propose alternatives**: When the user shares an idea, do not just agree. Respond with *"What about X instead?"* or *"Have you considered Y?"* to generate options they may not have thought of.
*   **Push back when warranted**: If an idea has a meaningful downside (maintenance burden, complexity, security risk), say so directly. Do not soften valid concerns.
*   **Trade off explicitly**: Compare options on dimensions that actually matter for this decision (complexity, reversibility, performance, maintenance burden, type safety, and ease of explanation).
*   **Protect simplicity**: Before proposing a new abstraction, layer, configuration option, dependency, state model, or extension point, identify the current requirement that needs it. Record unsupported future ideas as possible follow-ups rather than adding them to the design.
*   **Keep it interactive**: Ask questions one at a time. Keep your responses conversational and engaging.

### 3. Conclude the Discussion
Continue the discussion until the user explicitly indicates that a decision is made or they are ready to proceed (e.g. they say "let's go with X" or "write a plan for this").
Once settled, recommend the next action (typically invoking `write-plan`).
