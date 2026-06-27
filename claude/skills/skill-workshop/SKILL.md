---
name: skill-workshop
description: Iteratively improve a skill using subagent consensus and simulation testing. Use when a skill is producing bad outputs, has unclear instructions, or you want to stress-test it before shipping. Runs proposal evaluation and scenario simulation rounds with multiple agents to surface issues and build confidence.
---

# Skill Workshop

An iterative loop for improving a SKILL.md using two distinct subagent phases: **consensus** (do proposed changes make sense in theory?) and **simulation** (does the skill produce good output in practice?). Repeat until the skill is behaving well.

## Phase 0 — Orient

1. Locate and read the target SKILL.md in full. Skills are typically found in a `skills/<name>/SKILL.md` directory — check the current project or any known skills directory in the environment. Read it before asking anything. If the file cannot be found, tell the user clearly, list the skills you can find, and offer three recovery paths: wrong name, create a new skill from scratch, or non-standard path. Do not proceed without a file to work from.
2. Ask the user: "What problem are you trying to fix, or what behaviour do you want to test? Even a vague sense of something feeling off is useful." If they already have a clear problem description, proceed directly.
3. If the user can't articulate a problem — or after one follow-up still can't — skip straight to Phase 2 (simulation) to discover issues empirically. Don't loop on clarification.

## Phase 1 — Proposal + Consensus

Use this phase when you have one or more proposed changes to evaluate before applying them.

1. Present your proposed changes clearly — show before/after diffs or describe the change in plain language.
2. Spawn **4 subagents in parallel**, each given:
   - The full current SKILL.md
   - The proposed change(s)
   - This prompt: *"Evaluate this proposal critically. Does it solve the stated problem? Is the wording clear and well-calibrated? Anything that should be added, removed, or tightened? Be direct and opinionated. Under 200 words."*
3. Synthesize the responses. Look for:
   - **Unanimous agreement** → apply with confidence
   - **Recurring criticisms** → fold them in before applying
   - **One-off objections** → use your judgment; note them to the user
4. Apply the changes, then proceed to Phase 2 to verify in practice. Do not commit yet — only commit at the stopping condition.

## Phase 2 — Scenario Simulation + Evaluation

Use this phase to test whether the skill's instructions actually produce good outputs.

### Generating scenarios

Design 4 scenarios that stress-test different edges of the skill. Think about:
- A case where the answer is obvious and simple (does the skill over-engineer it?)
- A case where context genuinely changes the right answer (does the skill ask or assume?)
- A case where there are many possible paths (does the skill handle ambiguity well?)
- A general / mixed case (holistic evaluation)

**Ask the user** if they want to suggest scenarios or if you should generate them. If they defer, generate them yourself — tailor them to the skill's domain so they feel realistic, not generic.

### Running the simulation

Spawn **4 subagents in parallel**, each given:
- The full current SKILL.md
- Their specific scenario (a realistic input the skill would receive)
- This prompt: *"(1) Simulate running this skill with the scenario below — produce the output the skill would generate, following the instructions faithfully. (2) Then write a short critical evaluation (under 150 words): what did the skill handle well? What felt missing, awkward, or likely to produce bad outputs across other inputs? Suggest specific changes if you have them."*

### Synthesizing results

After all 4 return:
1. Show the user the outputs if they're interesting — highlight best and worst.
2. Extract recurring issues (things **2+ agents flagged independently**) and one-off issues (single agent, may still be valid).
3. Present a prioritised list of proposed fixes, ranked by: loop-breaking bugs first → stuck-state bugs → UX gaps → polish.
4. Return to Phase 1 to evaluate the fixes, then re-run Phase 2 to verify.

## Stopping condition

Stop when:
- A simulation round produces no recurring issues (recurring = flagged independently by 2 or more agents), and
- The user is happy with the sample outputs

Then commit all changes in a single commit. Summarise what changed across all iterations in the commit message. Confirm the message with the user before committing if the changes were substantial.

## What to avoid

- Applying changes without a consensus round — proposals that seem obvious often have non-obvious downsides
- Running identical scenarios across all 4 agents — varied inputs surface different failure modes
- Treating one-off agent objections as gospel — single-agent criticism may reflect the agent's bias, not a real problem
- Iterating forever — if two simulation rounds produce no new recurring issues, the skill is good enough; ship it
- Asking the user to evaluate every minor wording tweak — make small improvements yourself and reserve user input for structural decisions
- Committing mid-loop — only commit once the stopping condition is met
- If the user rejects all proposals and no new ones are ready, move directly to Phase 2 rather than asking the user what to do next
