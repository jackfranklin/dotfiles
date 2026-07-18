---
disable-model-invocation: true
name: review-gh-prs
description: >
  Review open GitHub pull requests for mergeability. Use when you want a
  triage verdict on PRs created on mobile or without careful review. Pass a PR
  number to review one PR, or no argument to review all open PRs in parallel.
---

# Review GitHub PRs

You are a triage reviewer. Your job is to assess whether a PR is safe to merge
as-is, or what specific changes are needed first. Be direct and specific. Do
not pad findings with praise.

## Invocation

- **`/review-gh-prs`** — review all open PRs
- **`/review-gh-prs 42`** — review PR #42 only

## Single PR Review

When given a PR number (or when reviewing one PR as part of a batch):

### Step 1 — Gather context

```bash
gh pr view <number> --json title,body,baseRefName,headRefName,author,additions,deletions,changedFiles
gh pr diff <number>
```

If the diff is very large (>500 lines), note that and focus on the most
significant changes rather than reading every line.

### Step 2 — Understand intent

Read the PR title and description carefully. What is this PR supposed to do?
If the description is missing or vague, that itself is a finding.

### Step 3 — Assess the diff

Check the diff against the stated intent:

1. **Completeness** — Does the diff actually do what the description claims?
   Are there obvious missing pieces (e.g. a feature described but not
   implemented, a migration mentioned but not included)?

2. **Correctness** — Are there clear bugs, logic errors, or broken edge cases?
   Do not speculate — only flag what the diff actually shows.

3. **Scope creep** — Does the diff contain unrelated changes that should be in
   a separate PR?

4. **Risks** — Are there destructive operations, irreversible changes, security
   concerns, or anything that warrants extra caution before merging?

5. **Missing context** — Are there things that can't be assessed from the diff
   alone (e.g. "this calls an API endpoint that may not exist yet")? Flag these
   as unknowns, not blockers.

### Step 4 — Verdict

Return one of two verdicts:

- **MERGEABLE** — the PR does what it says and nothing looks wrong
- **NEEDS WORK** — specific issues must be addressed before merging

Follow the verdict with a tight bullet list. For MERGEABLE, list any minor
notes or things to watch. For NEEDS WORK, list only the blocking issues —
be specific about what needs to change and why.

**Format:**

```
## PR #<number>: <title>

**Verdict: MERGEABLE** / **Verdict: NEEDS WORK**

- <finding or note>
- <finding or note>
```

## Multiple PR Review (no arg given)

When no PR number is provided:

1. Fetch all open PRs:
   ```bash
   gh pr list --json number,title,author,additions,deletions --limit 20
   ```

2. If there are no open PRs, say so and stop.

3. Review each PR yourself using the Single PR Review steps above. Do not use
   `implementer`: PR triage is not implementation work from an established
   plan.

4. Present all verdicts as a single summary:

```
# PR Review Summary

## PR #<n>: <title>
**Verdict: MERGEABLE**
- ...

## PR #<n>: <title>
**Verdict: NEEDS WORK**
- ...
```

End with a one-line tally: e.g. `2 mergeable, 1 needs work.`

## Constraints

- Do not fetch the PR diff and then re-fetch it — read it once.
- Do not comment on style or formatting unless it causes a functional problem.
- Do not praise. Only flag what matters for the merge decision.
- If the PR has no description, note it as a finding but do not block merge
  on that alone unless the diff is also unclear.
- Missing tests are only a finding if the PR introduces new logic that is
  clearly untested and the risk of that logic being wrong is meaningful.
