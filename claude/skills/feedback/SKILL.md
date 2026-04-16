---
name: feedback
description: Manage feedback and bug reports for a project using a local SQLite database. Use when the user asks to log, list, view, resolve, or work through feedback items or bugs.
user-invocable: false
---

You have access to a feedback tracking CLI at `~/dotfiles/claude/skills/feedback/feedback`.

Run it with:
```
~/dotfiles/claude/skills/feedback/feedback <command>
```

## Commands

```
feedback add --project <name> --title "..." [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
feedback list [--project <name>] [--all]
feedback show <id>
feedback done <id>
feedback edit <id> [--title "..."] [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
feedback projects
```

## Rules

**Always `list` before `show`.** The list command returns only titles and IDs — it is token-efficient. Only call `show <id>` when you need the full detail of a specific item.

**Default is open items only.** `list` excludes done items unless `--all` is passed. This is correct behaviour — do not add `--all` unless the user specifically asks to see completed items.

**Always pass `--project`.** Infer the project name from the current working directory or from context the user has provided. If ambiguous, ask the user before running any command.

**Priorities:** `high` for bugs or blockers, `medium` for improvements (default), `low` for nice-to-haves.

**Statuses:** `open` (default), `in-progress`, `blocked`, `done`. Use `done <id>` or `edit <id> --status done` to close items. The `list` command excludes `done` items unless `--all` is passed.

**Categories:** Free-text tag (e.g. `bug`, `ux`, `performance`, `gameplay`). Shown in list output as `{category}`.

## Typical flows

**Logging new feedback from a conversation:**
1. For each item the user wants to record, run `add` with an appropriate title, detail, and priority.
2. Confirm how many items were added.

**Working through feedback:**
1. Run `list --project <name>` to get open items.
2. Present the titles to the user and ask which to tackle.
3. Run `show <id>` only for items being actively discussed.
4. After an item is resolved, run `done <id>`.

**User asks "what's left?":**
1. Run `list --project <name>` and present the output directly.
