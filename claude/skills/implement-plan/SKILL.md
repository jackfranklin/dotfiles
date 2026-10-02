---
name: implement-plan
description: Implements an explicitly approved, scoped code change safely and autonomously. Use when transitioning from an agreed plan to source or test changes; do not use for exploration or unresolved design decisions.
---

# Implement an Approved Plan

Use this skill only to implement a defined change. Do not start source-code changes until the plan is clear and the user has authorized implementation.

## Non-negotiable rules

1. **Implement only a clear plan.** Read the plan, relevant source, tests, and repository instructions. Confirm the intended behavior, scope, constraints, affected files, and acceptance criteria. If any material detail is ambiguous, stale, contradictory, or missing, stop before editing and explain the gap with a focused question. Do not fill in requirements from guesswork.
2. **Resolve ordinary implementation friction autonomously.** Continue through incomplete intermediate states, type errors caused by the current refactor, test failures that can be investigated from repository evidence, and fixture or test-harness changes required by the approved plan. Stop only when resolving the issue requires a material product decision, changes the approved scope, needs unavailable access or secrets, risks data loss, or cannot be resolved from repository evidence. When stopping is necessary, explain the concrete blocker and ask one focused question; do not merely announce a pause.
3. **Use an implementation branch by default; honor explicit authorization to work on `main`.** Before any source or test edit, inspect the Git state. Start from a clean worktree and create/switch to a new, clearly named feature branch unless the user explicitly authorizes implementation on `main` for the current task. That authorization permits source edits and commits directly on `main`; do not require a branch or ask again. If the worktree is dirty, the current branch is not suitable, or branch creation would discard/conflict with work, stop and ask for guidance.
4. **Test thoroughly by default.** Add or update focused unit tests unless the user explicitly says not to. Cover required happy paths, meaningful boundaries, failure/empty states, and behavior likely to regress from the change. Follow repository test conventions; do not add redundant or speculative tests merely to increase the count.
5. **Prefer the simplest clear implementation.** Make the narrowest change that meets the approved plan. Prefer direct, readable code over a new abstraction, layer, configuration option, dependency, state model, or extension point. Introduce one only when a current requirement, two real current use cases, or an established repository convention justifies it. Do not refactor nearby code merely to make the change feel cleaner.

## Working mode

During an approved implementation, keep taking the next concrete investigation, edit, or verification step. Do not end a response merely to provide a progress update, announce the next step, or ask for confirmation already supplied. Return to the user only with a completed result or a genuine blocker under rule 2.

## Workflow

### 1. Preflight

- Read the nearest applicable `AGENTS.md`, contributor guidance, and relevant task/issue/PR material.
- Inspect the current implementation, related tests, existing utilities, and recent relevant changes before designing new code.
- Check `git status --short` and the current branch.
- Establish the implementation understanding, including non-goals and acceptance criteria. Do this silently unless a material ambiguity requires a focused question.

### 2. Branch safely

- If currently on `main` with a clean worktree, create and switch to a descriptive branch (for example, `feature/issue-123-short-description`) unless the user explicitly authorized implementation on `main` for this task. When such authorization was given, work on `main` without requesting branch confirmation.
- If already on an explicitly designated, clean implementation branch, confirm it is appropriate before using it.
- Never use forceful Git operations, overwrite unrelated changes, or alter another branch's history without explicit user authorization.

### 3. Confirm the test plan

Before writing tests, derive the specific test cases to add or change from the approved plan and repository guidance. Ask the user only when repository guidance explicitly requires test-plan approval or the expected behavior is materially ambiguous.

Implement tests and the smallest clear production change that satisfies the plan. Reuse an existing abstraction when it fits; otherwise prefer local, direct code to creating a new general abstraction for one use case. Keep unrelated cleanup out of the change.

### 4. Validate continuously

- Run the repository-required typecheck/lint command before tests when instructed by project guidance.
- Run focused tests while implementing, then the required broader verification once the change is complete.
- Investigate and fix failures attributable to the in-progress implementation. Do not weaken tests to hide a defect. Stop only for a failure that is pre-existing, unrelated, or cannot be resolved from repository evidence; report the evidence and its impact.
- Check formatting and inspect the final diff for unintended changes, missing tests, debug code, deviations from the approved scope, and indirection that can be removed without losing a current requirement.

### 5. Commit logical, verified increments

Commit each independently coherent, verified unit of work as soon as it is complete—for example, a focused behavior change with its tests, followed by a separate integration or documentation change. Before each commit, inspect the relevant status and diff, and commit only files within the approved scope with a concise message describing that unit.

Do not create artificial, incomplete, or WIP commits. Keep production code and the tests that establish its behavior together when they form one logical unit. For small or indivisible work, one final commit is correct; use multiple commits only when the implementation naturally proceeds in separable, reviewable stages.

Do not amend, force-push, or include unrelated user changes.

### 6. Push and open a pull request

After the full change passes its required verification, inspect the final Git status and diff. Commit any remaining complete logical unit; do not manufacture a final commit when none remains.

Inspect the branch's configured remote URL. If it is hosted on GitHub, push the implementation branch and create a pull request against the repository's default branch with `gh`. Use the branch's commit series to provide a clear PR title and description. If a pull request for that branch already exists, do not create a duplicate; report its URL instead. If the remote is not GitHub, do not push or create a pull request.

Do not merge branches or modify issue state unless the user explicitly requests it. Never force-push or perform destructive remote operations without explicit user authorization.

### 7. Report and hand off

Report:

- branch name and commit SHA(s), in commit order;
- files changed and the behavior implemented;
- tests and verification commands run, with results;
- pull request URL when one was created or already existed, or that no GitHub remote was configured;
- anything not run or any remaining manual checks;
- any intentional deviations from the plan, which require prior user approval;
- complexity deliberately avoided, and any new abstraction or moving part with its present-day justification.
