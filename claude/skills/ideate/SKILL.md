---
name: ideate
description: Spawns 3 subagents (Innovator, Skeptic, Pragmatist) to explore different approaches to a problem or question, then synthesizes their findings and recommends the best approach.
---

# Ideate Skill

When the user asks to "ideate", "brainstorm", or "explore approaches" for a problem or question, execute the following workflow:

1. **Understand & Define the Problem**:
   - Determine the specific problem, query, or architecture decision the user wants to address. If it's ambiguous or lacks context, ask the user to clarify before proceeding.
   
2. **Invoke Specialized Subagents in Parallel**:
   - Invoke three subagents concurrently using the `invoke_subagent` tool:
     * **Innovator** (`ideate_innovator`): To explore creative, forward-looking, and ideal solutions.
     * **Skeptic** (`ideate_skeptic`): To analyze risks, bottlenecks, complexities, hidden assumptions, and missing gaps in the spec/problem.
     * **Pragmatist** (`ideate_pragmatist`): To outline the simplest, lowest-friction, and fastest path.
   - Pass the identical user prompt/question to all three subagents.

3. **Aggregate and Synthesize Findings**:
   - Wait for all three subagents to finish.
   - Summarize the key findings from each agent in a structured format (e.g. bullet points or a comparison table).
   - Detail the trade-offs:
     * What does the ideal solution offer?
     * What are the primary concerns/risks?
     * How can we build it immediately with minimal fuss?

4. **Recommend the Optimal Hybrid Approach**:
   - Formulate a recommendation that balances the pragmatist's speed, the innovator's vision, and the skeptic's safety guardrails.
   - Clearly state *why* this path is chosen.
   - Present this to the user for feedback.
