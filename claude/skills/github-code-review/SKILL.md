---
name: github-code-review
description: >
  Perform a thorough, read-only review of one GitHub pull request. Use when
  given a GitHub PR number and you need to understand its linked issue(s), all
  existing discussion and review feedback, and independently apply the
  code-review skill to the exact PR code.
disable-model-invocation: true
compatibility: Requires gh authenticated for the target repository, git, and a local clone of that repository.
---

# GitHub Code Review

Review exactly one GitHub pull request. This skill supplies GitHub context and
an isolated checkout; **`code-review` remains the governing implementation
review standard.** Be direct and evidence-based. Do not praise, approve, post
GitHub comments, modify the active checkout, or run tests unless the user
separately asks.

## Invocation

```text
/github-code-review 42
```

Require one positive integer PR number. If it is missing or invalid, ask for
it. Do not review every open PR as a fallback.

## Workflow

### 1. Establish GitHub context

From the repository containing the active checkout, collect the PR metadata
and its patch. Use the explicit repository argument in later `gh` commands so
changing directories cannot change the target repository.

```bash
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
gh pr view <number> -R "$repo" --json number,title,url,body,state,author,baseRefName,baseRefOid,headRefName,headRefOid,commits,files,additions,deletions,changedFiles,closingIssuesReferences,comments,reviews
gh pr diff <number> -R "$repo" --patch
```

Read the title and body before inspecting the implementation. Identify the
claimed problem, expected outcome, scope, and any unstated assumptions. A
missing or vague description is relevant context, but is not automatically a
blocking finding.

### 2. Read linked issues

Use the structured `closingIssuesReferences` returned by the PR metadata. Read
every linked issue, including its title, body, state, labels, and comments:

```bash
gh issue view <issue-url> --json number,title,url,state,labels,body,comments
```

A closing reference is authoritative; do not guess linked issues by grepping
arbitrary `#123` text in prose. If no issues are linked, report that limitation
rather than inventing one.

### 3. Read all prior PR feedback

Read all three categories of feedback:

1. PR conversation comments (`comments` from `gh pr view`);
2. submitted reviews and their bodies (`reviews` from `gh pr view`);
3. inline review threads, including their resolved and outdated state.

For inline threads, query GitHub's `reviewThreads` GraphQL connection. Request
the thread path, current/original line, `isResolved`, `isOutdated`, and every
comment's author, body, URL, and timestamp:

```bash
owner="${repo%%/*}"
name="${repo##*/}"
query='query($owner: String!, $name: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $cursor) {
        nodes {
          isResolved isOutdated path line originalLine
          comments(first: 100) {
            nodes { author { login } body url createdAt }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
gh api graphql -f query="$query" -F owner="$owner" -F name="$name" -F number=<number>
```

Use each returned `endCursor` in the next request until `hasNextPage` is false.
Do not substitute the REST pull-request-comments endpoint: it cannot reliably
report thread resolution state.

Treat existing feedback as input to verify, not as conclusions to repeat. For
each substantive concern, classify it as one of:

- **Still open** — the current PR still has the problem.
- **Resolved** — the current code addresses it.
- **Stale or not applicable** — the code changed, the thread is outdated, or
  the concern is unsupported by the current implementation.
- **Needs author decision** — it is a product or design question that cannot
  be settled from the code and issue.

### 4. Create an isolated PR worktree

Review the actual PR head in a temporary detached Git worktree, never in the
user's active checkout. First obtain the PR's `baseRefName` from step 1. Create
unique temporary refs in the local repository, add the worktree, and register
cleanup **before** fetching:

```bash
repo_root="$(git rev-parse --show-toplevel)"
pr=<number>
base=<baseRefName-from-step-1>
nonce="$(date +%s)-$$"
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/github-code-review-pr-${pr}-XXXXXX")"
worktree="$tmp_root/repo"
head_ref="refs/github-code-review/pr-${pr}-${nonce}"
base_ref="refs/github-code-review/base-${pr}-${nonce}"

cleanup() {
  git -C "$repo_root" worktree remove --force "$worktree" 2>/dev/null || true
  git -C "$repo_root" update-ref -d "$head_ref" 2>/dev/null || true
  git -C "$repo_root" update-ref -d "$base_ref" 2>/dev/null || true
  rm -rf "$tmp_root"
}
trap cleanup EXIT HUP INT TERM

git -C "$repo_root" fetch --no-tags origin \
  "+refs/pull/${pr}/head:${head_ref}" \
  "+refs/heads/${base}:${base_ref}"
git -C "$repo_root" worktree add --detach "$worktree" "$head_ref"
cd "$worktree"
```

If `origin` is not the GitHub remote for the PR, identify the matching remote
first. If the fetch or worktree setup fails, explain the failure and do not
silently review the active checkout instead.

Never use `git checkout`, `git switch`, `git reset`, `git stash`, `git clean`,
or `gh pr checkout` in the active checkout. The temporary refs and worktree
must be removed through `cleanup` even if the review cannot finish.

### 5. Perform the implementation review

Load and apply the sibling [`code-review`](../code-review/SKILL.md) skill now.
It defines the review principles and full implementation checklist. For its
context/diff step, use the isolated worktree and this exact PR range instead
of staged or unstaged changes:

```bash
git diff "$base_ref...HEAD"
```

Read relevant unchanged code in the worktree: callers, types, constants,
existing utilities, tests, and local repository instructions. Review the code
independently; prior reviewer comments may guide investigation but never
replace it.

### 6. Report

Use this format. Findings must identify a current location where possible,
explain the concrete consequence, and recommend a correction. Do not duplicate
existing feedback as a new finding; cross-reference it under existing feedback
instead.

```md
# GitHub Code Review — PR #<number>: <title>

## Intent
- PR: <your concise interpretation of the PR's intended change>
- Linked issue(s): <issue number/title and relevant acceptance criteria, or none>
- Scope assessed: <notable files or areas>

## Existing feedback reconciled
- **Still open** — <author and concern> (`path:line`)
- **Resolved** — <author and concern>
- **Stale or not applicable** — <author and reason>
- **Needs author decision** — <question>

## New findings
### Critical
- `path:line` — <problem, consequence, and correction>

### Important
- `path:line` — <problem, consequence, and correction>

### Minor
- `path:line` — <problem, consequence, and correction>

## Review limits
- <only genuine limitations, such as no linked issue or unavailable content>
```

Omit empty severity sections. If no new findings exist, say `No new findings.`
Do not claim that the PR is mergeable or approved: the output is a thorough
code review, not a merge-decision shortcut.
