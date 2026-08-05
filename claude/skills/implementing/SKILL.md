---
name: implementing
description: Implements an approved code-change plan safely. Use when beginning a feature, bug fix, or refactor that requires source changes, tests, a dedicated branch, and explicit handling of ambiguity or unexpected blockers.
disable-model-invocation: true
---

# Implementing an Approved Plan

Use this skill only to implement a defined change. Do not start source-code changes until the plan is clear and the user has authorized implementation.

## Non-negotiable rules

1. **Implement only a clear plan.** Read the plan, relevant source, tests, and repository instructions. Confirm the intended behavior, scope, constraints, affected files, and acceptance criteria. If any material detail is ambiguous, stale, contradictory, or missing, stop before editing and explain the gap with a focused question. Do not fill in requirements from guesswork.
2. **Pause on surprises.** If implementation reveals an unexpected challenge or roadblock—such as incompatible existing behavior, a missing dependency or API, a plan assumption that is false, an unexplained test failure, a required design choice, or scope growth—stop work immediately. Explain what happened, its impact, options if useful, and ask the user how to proceed. Do not silently choose a workaround.
3. **Never implement a feature on `main`.** Before any source or test edit, inspect the Git state. Start from a clean worktree and create/switch to a new, clearly named feature branch. If the worktree is dirty, the current branch is not suitable, or branch creation would discard/conflict with work, stop and ask for guidance. Do not commit feature work directly to `main`.
4. **Test thoroughly by default.** Add or update focused unit tests unless the user explicitly says not to. Cover happy paths, boundaries, failure/empty states, and behavior likely to regress from the change. Follow repository test conventions; do not add redundant tests merely to increase the count.

## Workflow

### 1. Preflight

- Read the nearest applicable `AGENTS.md`, contributor guidance, and relevant task/issue/PR material.
- Inspect the current implementation, related tests, existing utilities, and recent relevant changes before designing new code.
- Check `git status --short` and the current branch.
- Summarize the implementation understanding, including non-goals and acceptance criteria. If anything is unclear, stop and ask.

### 2. Branch safely

- If currently on `main` with a clean worktree, create and switch to a descriptive branch (for example, `feature/issue-123-short-description`).
- If already on an explicitly designated, clean implementation branch, confirm it is appropriate before using it.
- Never use forceful Git operations, overwrite unrelated changes, or alter another branch's history without explicit user authorization.

### 3. Confirm the test plan

Before writing tests, list the specific test cases to add or change and ask the user to approve them whenever repository guidance requires it. The list should name each behavior and expected result, including meaningful edge cases.

After approval, implement tests and the smallest clear production change that satisfies the plan. Reuse existing abstractions rather than duplicating behavior, and keep unrelated cleanup out of the change.

### 4. Validate continuously

- Run the repository-required typecheck/lint command before tests when instructed by project guidance.
- Run focused tests while implementing, then the required broader verification once the change is complete.
- Treat any unexplained failure as a roadblock: stop, report it, and ask for advice rather than masking it or weakening tests.
- Check formatting and inspect the final diff for unintended changes, missing tests, debug code, and deviations from the approved scope.

### 5. Report and hand off

Report:

- branch name;
- files changed and the behavior implemented;
- tests and verification commands run, with results;
- anything not run or any remaining manual checks;
- any intentional deviations from the plan, which require prior user approval.

Do not merge, push, open a pull request, modify issue state, or perform other remote side effects unless the user asks.
