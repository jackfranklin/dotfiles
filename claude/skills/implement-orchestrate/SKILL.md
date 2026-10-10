---
name: implement-orchestrate
description: Implement an approved plan as an orchestrator — sub-agents write each task, parallel sub-agents review it, you verify and commit.
disable-model-invocation: true
---

# Orchestrate an Approved Plan

Read `~/.claude/skills/implement-plan/SKILL.md` first. Every rule and workflow step in it applies unchanged; it is the single source of truth for scope, branching, testing, simplicity, commits, PRs, and the final report. This skill changes only **who does the work**: you are the orchestrator, sub-agents are the hands and the fresh eyes.

Invoking this skill is the user's explicit authorization to spawn sub-agents.

## Orchestrator rules

1. **You own Git.** Only you branch, stage, commit, push, and open the PR. Sub-agents edit files and nothing else — tell every implementer: "Do not run any git command that changes state."
2. **Trust nothing reported.** A sub-agent saying "tests pass" or "done" is a claim, not evidence. Before accepting a task you run the verification commands yourself and read the full diff.
3. **Serial by default.** Implement tasks one at a time in the shared worktree. Run implementers in parallel only when the plan marks tasks independent _and_ their file sets are disjoint; give each `isolation: "worktree"` and merge their results yourself, one task at a time.
4. **The plan is the scope boundary — for reviewers too.** A finding is fixed now only if it is a defect, a plan violation, or a missing test the plan requires. Anything else, however good, is deferred to the final report. The `diff-reviewer` agent applies this rule when it labels findings; you apply it again in triage.
5. **Bounded loops.** At most two review → fix rounds per task. If the third review still has fix-now findings, stop and escalate to the user with the outstanding findings.
6. **Escalate blockers, don't absorb them.** Sub-agents cannot ask the user. When one returns `BLOCKED: <question>`, answer it only if the plan or repository evidence settles it; otherwise apply implement-plan rule 2 and ask the user.

## Workflow

### 1. Preflight and branch

Do implement-plan steps 1–2 yourself. Then split the plan into its tasks and, for each, record: files it touches, verification commands, and whether it is independent of the others.

**Done when** every plan task has a file set and verification command, and you are on a clean implementation branch.

### 2. For each task: implement

Spawn an implementer sub-agent (`general-purpose`). Its brief contains:

- the task text verbatim from the plan, plus the plan's non-goals;
- the path to implement-plan's SKILL.md, with the instruction to follow its rules 1, 2, 4, and 5 — but to return `BLOCKED: <question>` rather than asking the user, and not to touch Git;
- relevant repository guidance paths (`AGENTS.md`, `CLAUDE.md`);
- what to return: files changed, tests added, commands run, any deviation from the task.

Keep its agent ID; you will resume it for fixes.

**Done when** the implementer has returned and you have run the task's verification commands yourself and they pass, and the diff contains only files within the task's scope. If not, resume the implementer with the concrete failure.

### 3. For each task: review in parallel

Run `git add -N .` so new files appear in the diff, then write it with `git diff > <scratchpad>/task-<n>.diff` (reviewers have no shell). Size the review from the diff, not the plan's description of it:

| Reviewers | When | Lenses per reviewer |
| :- | :- | :- |
| 1 | Small and low-risk: one or two files, a direct change following an existing pattern | all three |
| 2 | Moderate: several files, new logic, or new tests of non-trivial behavior | conformance + correctness / maintainability |
| 3 | Large or risky: touches concurrency, persistence, security, public interfaces, or error handling across a boundary | one each |

When in doubt between two rows, take the larger. Spawn the reviewers as `diff-reviewer` sub-agents in a single message. Each brief contains the task text verbatim, the plan's non-goals, the diff file's absolute path, and its lenses. On a re-review, write a fresh diff file first.

**Done when** every reviewer has returned, and you have recorded the reviewer count with a one-line reason.

### 4. For each task: triage, fix, commit

Verify every `fix-now` finding against the code yourself; reviewers are wrong sometimes. Sort each into **fix**, **defer** (report it), or **reject** (record one line of reasoning). Resume the implementer with the **fix** list only. Re-verify (step 2's criterion), then re-review only if the fixes were non-trivial, within rule 5's limit.

Commit the task per implement-plan step 5.

**Done when** the task is committed and every finding is accounted for as fixed, deferred, or rejected.

### 5. Finish

Do implement-plan steps 6–7. Add to the report:

- per task: reviewer count and reason, review rounds used, and findings fixed / deferred / rejected (with the rejection reasons);
- all deferred findings, grouped, as candidate follow-ups.
