# Engineering Workflow

How the skills fit together across the software engineering cycle.

---

## 1. Exploring an idea

Not sure if something is worth building, or how to approach it?

- `/ideate` — brainstorm approaches before committing to one
- `/grill-me` — stress-test a plan or design via relentless questioning

---

## 2. Before implementation

Run these before writing a plan or any code.

- `/preflight` — Ponytail ladder: is this necessary? does stdlib/a dep cover it? what's the minimum? Outputs findings and a verdict on what to build (and what not to).
- `/verify-plan-assumptions` — if you have a spec or PRD, cross-reference it against the live codebase to catch stale assumptions before they become bugs

---

## 3. Planning

- `/write-detailed-implementation-plan` — rigorous TDD plan with exact file paths, real code in every step, interface contracts between tasks. Saves to `.jai/detailed-plans/`. Use after preflight has settled scope.
- `/review-plan` — open a plan in the browser for inline annotation before execution

---

## 3a. Starting a fresh implementation session

Open a new conversation and run this before any code is written.

- `/onboard-plan <path or description>` — reads the plan cold via two independent sub-agents, surfaces every comprehension gap (ambiguous terms, undefined references, missing context), and resolves them with you before execution begins. Focuses on *understanding*, not critique — use `/preflight`, `/verify-plan-assumptions`, or `/design-discussion` for that.

---

## 4. During implementation

- `/verify-mechanical-change` — confirm a change is purely mechanical before treating it as safe to land without review
- `/adr` — capture a significant architectural decision while the reasoning is fresh

---

## 5. After implementation

- `/nuclear-code-review` — aggressive review focused on deleting complexity and improving maintainability
- `/automated-doubt` — audit from multiple critical perspectives (type safety, security, concurrency, public interfaces)
- `/code-simplifier` — runs quality, reuse, and efficiency reviewers together
- `/fresh-eyes-amend` — review recent changes as if seeing them for the first time
- `/review-diff` — straightforward diff review

---

## 6. Understanding code

- `/walkthrough` — interactive explanation of a git diff, structured by concept rather than file

---

## 7. Documentation and handoff

- `/doc-clarity-opportunity` — find opportunities to improve docs and code clarity
- `/handoff` — summarise in-progress work for a future session or another engineer
- `/handoff-search` — search existing handoff documents

---

## 8. Ongoing

- `/later` — log something to come back to without losing your current thread
- `/jack-references` — save or search technical reference material
