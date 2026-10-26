---
name: implement-orchestrate
description: Implement an approved plan as an orchestrator — sub-agents write each task, parallel sub-agents review it, you verify and commit.
disable-model-invocation: true
---

# Orchestrate an Approved Plan

Read `{{skills_dir}}/implement-plan/SKILL.md` first. Every rule and workflow step in it applies unchanged; it is the single source of truth for scope, branching, testing, simplicity, commits, PRs, and the final report. This skill changes only **who does the work**: you are the orchestrator, sub-agents are the hands and the fresh eyes.

Invoking this skill is the user's explicit authorization to spawn sub-agents.

## Orchestrator rules

1. **You own Git.** Only you branch, stage, commit, push, and open the PR. Sub-agents edit files and nothing else — tell every implementer: "Do not run any git command that changes state."
2. **Trust nothing reported.** A sub-agent saying "tests pass" or "done" is a claim, not evidence. Before accepting a task you run the verification commands yourself and read the full diff.
3. **Serial by default.** Implement tasks one at a time in the shared worktree. {{#claude}}Run implementers in parallel only when the plan marks tasks independent _and_ their file sets are disjoint; give each `isolation: "worktree"` and merge their results yourself, one task at a time.{{/claude}}{{#pi}}Pi subagents cannot be isolated in separate worktrees, so never run implementers in parallel.{{/pi}}
4. **The plan is the scope boundary — for reviewers too.** A finding is fixed now only if it is a defect, a plan violation, a missing test the plan requires, or a verified high-value documentation finding within the changed behavior. Anything else, however good, is deferred to the final report. `code-reviewer` and `documentation-reviewer` apply distinct correctness and documentation lenses; you verify their findings again in triage.
5. **Bounded loops.** At most two review → fix rounds per task. If the third review still has fix-now findings, stop and escalate to the user with the outstanding findings.
6. **Escalate blockers, don't absorb them.** Sub-agents cannot ask the user. When one returns `BLOCKED: <question>`, answer it only if the plan or repository evidence settles it; otherwise apply implement-plan rule 2 and ask the user.

## Workflow

### 1. Preflight and branch

Do implement-plan steps 1–2 yourself. Then split the plan into its tasks and, for each, record: files it touches, verification commands, and whether it is independent of the others.

**Done when** every plan task has a file set and verification command, and you are on a clean implementation branch.

### 2. For each task: implement

Spawn an `implementer` sub-agent. Its brief contains:

- the task text verbatim from the plan, plus the plan's non-goals;
- the path to implement-plan's SKILL.md, with the instruction to follow its rules 1, 2, 4, and 5 for implementation and verification — except that the parent owns the `code-reviewer` and `documentation-reviewer` instructions in the workflow's **Validate continuously** step — to return `BLOCKED: <question>` rather than asking the user, and not to touch Git;
- relevant repository guidance paths (`AGENTS.md`, `CLAUDE.md`);
- what to return: files changed, tests added, commands run, any deviation from the task.

{{#claude}}
Keep its agent ID; you will resume it for fixes with SendMessage.
{{/claude}}
{{#pi}}
Pi subagents cannot be resumed. Keep its brief: for fixes, start a new `implementer` with the original brief, a summary of the current diff, and the failure or fix list.
{{/pi}}

**Done when** the implementer has returned and you have run the task's verification commands yourself and they pass, and the diff contains only files within the task's scope. If not, {{#claude}}resume the implementer{{/claude}}{{#pi}}start a new implementer as described above{{/pi}} with the concrete failure.

### 3. For each task: review in parallel

After the task passes its verification commands, determine its exact Git review range and affected paths. If the task has untracked files, run `git add -N -- <untracked task files>` so they appear in that diff without staging their contents. Spawn a `code-reviewer` subagent for every task and, when the task adds or changes public APIs or conceptually non-obvious behavior, a `documentation-reviewer` subagent in the same message. These agents have static Git inspection tools; do not create a diff scratch file for them.

Each brief contains the task text verbatim, its non-goals, acceptance criteria, the exact review range, affected paths, and the intended behavior. The documentation-reviewer brief also requests only high-value, in-scope JSDoc, explanatory-comment, and documentation-drift findings. On a re-review, provide the refreshed range and affected paths.

**Done when** each required reviewer has returned and you have recorded the reviewer set with a one-line reason.

### 4. For each task: triage, fix, commit

Verify every finding against the code yourself; reviewers are wrong sometimes. Sort each into **fix**, **defer** (report it), or **reject** (record one line of reasoning). A verified **Fix now** finding from documentation-reviewer is fixed when it documents changed public or non-obvious behavior and remains within the plan's scope. {{#claude}}Resume the implementer{{/claude}}{{#pi}}Start a new implementer as described in step 2{{/pi}} with the **fix** list only. Re-verify (step 2's criterion), then re-review only if the fixes materially change behavior, within rule 5's limit.

Commit the task per implement-plan step 5.

**Done when** the task is committed and every finding is accounted for as fixed, deferred, or rejected.

### 5. Finish

Do implement-plan steps 6–7. Add to the report:

- per task: reviewer count and reason, review rounds used, and findings fixed / deferred / rejected (with the rejection reasons);
- all deferred findings, grouped, as candidate follow-ups.
