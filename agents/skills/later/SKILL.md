---
disable-model-invocation: true
name: later
description: Log items to come back to later — bugs found mid-task, feature ideas, project feedback — as GitHub Issues. Use when the user asks to log, list, view, or work through items saved for later.
---

Use `gh` to manage backlog items as GitHub Issues in the current repo.

## GitHub body safety — mandatory

Never pass issue Markdown through a shell-quoted `--body` argument. Markdown commonly contains backticks, `$`, or command examples; in double-quoted Bash strings those can execute shell command substitution and leak their output into GitHub.

- Always write issue bodies to a temporary file outside the repository with the file-writing tool, then use `gh ... --body-file /tmp/<descriptive>.md`.
- Never use `--body "..."`, `--body "$(...)"`, backticks inside shell strings, or an unquoted heredoc for issue content.
- If a shell heredoc is unavoidable, its delimiter must be single-quoted: `<<'EOF'`.
- After publishing Markdown, verify the stored body is literal Markdown. If it contains shell output or credentials, immediately delete or replace the comment, stop work, and tell the user to rotate exposed credentials.

## Before anything else

Verify there is a GitHub remote: `gh repo view --json nameWithOwner`. If it fails, stop and tell the user there is no GitHub remote — they need to be in a GitHub-backed repo to use this skill.

## Logging an item

Write `/tmp/<repository>-issue-<slug>.md` with the file-writing tool, then run:

```
gh issue create --title "<title>" --body-file /tmp/<repository>-issue-<slug>.md
```

Add labels if helpful (e.g. `--label bug`), but don't create labels that don't exist yet — only use labels already present in the repo.

Before creating, run `gh issue list --search "<title>"` to check for duplicates. If a near-match exists, show it to the user and ask whether to update that issue or create a new one.

## Listing open items

```
gh issue list --state open
```

## Viewing an item

```
gh issue view <number>
```

**Never jump straight into implementation after reading an issue.** After `gh issue view`, always: summarise the issue in your own words, investigate the relevant code enough to explain *why* it happens (root cause, not just symptoms), then present your thoughts — options, tradeoffs, a recommendation if you have one — and ask the user how they'd like to proceed. Only start editing code once the user has confirmed a direction. This applies even if the fix looks small or obvious.

## Closing an item

```
gh issue close <number>
```

## Working through items

1. Run `gh issue list --state open` to get open items.
2. Present the titles and ask which to tackle.
3. Run `gh issue view <number>` for items being actively discussed, then follow the discuss-before-implementation rule above.
4. After an item is resolved, run `gh issue close <number>`.

## Priorities

If the user specifies priority, map it to labels if they exist in the repo (`priority: high`, `priority: medium`, `priority: low`). Otherwise note priority in the issue body.
