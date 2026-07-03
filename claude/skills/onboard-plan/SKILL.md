---
disable-model-invocation: true
name: onboard-plan
description: >
  Gives a fresh agent a plan, audits it for comprehension gaps, and verifies
  technical assumptions against the codebase before implementation begins.
  Spawns a single sub-agent to perform both checks and presents the findings.
---

# Plan Onboarding

Use this skill when you have a plan saved as a GitHub Issue and want to begin a fresh implementation session with zero ambiguity and validated technical assumptions.

## Step 1: Resolve the Plan Issue

The skill argument may be:
- A GitHub issue number: fetch it directly with `gh issue view <number> --json title,body`.
- A fuzzy description (e.g. "the plan about auth refactor"): search with
  `gh issue list --search "[PLAN] <description>" --state open --json number,title`
  and pick the best match by title similarity. If more than one is plausible,
  ask the user to choose before proceeding.

## Step 2: Read the Plan

Read the full issue body. Do not summarise or paraphrase it at this stage.

## Step 3: Spawn the Verification Sub-agent

Spawn a single `research` or `self` subagent to audit the plan. It receives the raw plan text and this prompt:

```
You are onboarding onto a new implementation plan. Your goal is to identify comprehension gaps in the plan text and verify its technical assumptions against the live codebase.

PLAN:
{PLAN_CONTENT}

Perform the following tasks:

1. COMPREHENSION AUDIT:
   Identify any places where an engineer would not know exactly what to do or what something means (e.g. undefined terms, ambiguous steps, sequencing issues).
   Formulate a list of questions for the user in the format:
   Q: [question]
   Where: [exact quote/step]

2. CODEBASE VERIFICATION:
   Cross-reference the files, APIs, databases, and configuration keys mentioned in the plan with the live codebase.
   Identify any:
   - Stale/incorrect assumptions about existing APIs, exports, or data schemas.
   - Mismatches in configuration or file layouts.
   - Hidden dependencies/prerequisites omitted from the plan.

Constraints:
- Do not suggest or make changes to the codebase.
- Rely only on live codebase verification (do not guess).
- Focus only on technical blocking issues.

Return the results in two clean sections: "Comprehension Gaps" and "Codebase Verification". No preamble, no summary.
```

## Step 4: Present to the User

Display the results returned by the subagent. Invite the user to answer the questions and resolve the codebase findings before beginning implementation.
