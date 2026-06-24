---
name: onboard-plan
description: >
  Gives a fresh agent a plan and has it surface every comprehension gap —
  ambiguous terms, missing context, undefined references — so the conversation
  starts with a fully shared understanding before any implementation begins.
  Spawns two independent sub-agents to maximise coverage, then synthesises
  their questions into a single prioritised list for the user to answer.
---

# Plan Briefing

Use this skill when you have a plan on disk and want to begin a fresh
implementation session with zero ambiguity. The goal is comprehension, not
critique — use `/preflight`, `/verify-plan-assumptions`, or
`/design-discussion` for that.

## Step 1: Resolve the Plan File

The skill argument may be:

- An exact file path: use it directly.
- A fuzzy description (e.g. "the plan about auth refactor"): list
  `.jai/detailed-plans/` and pick the best match by name similarity. If more
  than one file is plausible, ask the user to choose before proceeding.

## Step 2: Read the Plan

Read the full plan file into your context. Do not summarise or paraphrase it
at this stage.

## Step 3: Spawn Two Independent Sub-agents

Spawn both agents in parallel. Each receives the raw plan text and this
prompt — no other context about the project or the current conversation:

```
You are reading an implementation plan cold — you have no prior context
about the project, the codebase, or the conversation that produced this plan.

Your job is to identify every place where you, as the engineer about to
execute this plan, would not know exactly what to do or what something means.

Focus on comprehension gaps, not critique:
- Terms, names, or abbreviations that are used but not defined
- Steps that reference something (a file, a function, a concept, a system)
  without explaining what it is
- Anything where two engineers might reasonably interpret the instruction
  differently
- Context that seems assumed but isn't stated (e.g. "as discussed", "the
  existing X", "the usual pattern")
- Sequencing that is unclear — steps that seem to depend on something not
  yet introduced

Do NOT flag things like "is this the right approach?" or "should we use X
instead of Y?" — that is someone else's job.

For each gap, write a single clear question in the format:
  Q: [your question]
  Where: [quote the exact phrase or step that caused the confusion]

Return only the question list. No preamble, no summary.

---

PLAN:

{PLAN_CONTENT}
```

## Step 4: Synthesise

Once both agents respond:

1. Merge the two question lists.
2. Remove exact duplicates; where two questions address the same gap from
   different angles, combine them into one clear question.
3. Order by how blocking each gap is — questions that would stop an engineer
   from starting come first.

## Step 5: Present to the User

Display the synthesised question list clearly, numbered. Add a one-line
header stating which plan was reviewed.

Invite the user to answer each question. As they do, note the answers so
that by the end of the conversation both you and the user have a fully
aligned, unambiguous understanding of the plan ready to execute.

Do not begin implementation until the user indicates they are ready.
