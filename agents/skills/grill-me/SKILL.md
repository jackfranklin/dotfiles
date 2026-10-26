---
disable-model-invocation: true
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

## Choose the Interview Mode

Before asking substantive questions, determine whether the user wants **Discovery** or **Refinement** mode. If their request makes the mode clear, proceed without asking; otherwise, ask them to choose:

1. **Discovery mode** — use when the user is uncertain about the problem or wants to explore alternatives. Interview them relentlessly about the plan, explore viable design branches, resolve dependencies one by one, and provide a recommended answer for each question.
2. **Refinement mode** — use when the user has a bug report, issue, or mini-spec and wants to make it implementable. Treat the stated requirements as a strict boundary. Ask only questions needed to remove ambiguity, verify correctness, or choose among solutions that satisfy the stated scope. Prefer the smallest understandable solution and existing patterns over new abstractions or subsystems. Do not introduce adjacent features, cleanup, generalization, or speculative future-proofing; identify those separately as out of scope if relevant.

Examples: “explore options” selects Discovery mode; “flesh out this bug/spec” selects Refinement mode.

Ask questions one at a time. In either mode, stop when the user has a clear, bounded direction; do not continue exploring merely for completeness.

If a question can be answered by exploring the codebase, explore the codebase instead.

**Repository glossary:** At the start of the session, check whether `.jai/glossary.md` exists in the current repository. If it does, read it and use it as context. It is a stable glossary of canonical repository terminology and concepts, not a record of plan decisions, open questions, or this session's outcomes. Do not modify it during a grilling session.
