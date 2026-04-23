---
name: feedback
description: Manage feedback and bug reports for a project using a local SQLite database. Use when the user asks to log, list, view, resolve, or work through feedback items or bugs.
user-invocable: false
---

You have access to a feedback tracking CLI at `~/dotfiles/claude/skills/feedback/run`.

Run it with:

```
~/dotfiles/claude/skills/feedback/run <command>
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

1. Run `list --project <name>` to retrieve open items.
2. Scan the titles for any that overlap with or closely resemble the item(s) the user wants to log.
3. If you spot a potential duplicate or near-duplicate, call `show <id>` on the overlapping item, then present your findings to the user and ask: "This looks similar to #<id> — do you want to update that existing item or log a new one?"
4. Only proceed with `add` once the user has confirmed there is no overlap, or has explicitly asked for a new item.
5. Confirm how many items were added or updated.

**Working through feedback:**

1. Run `list --project <name>` to get open items.
2. Present the titles to the user and ask which to tackle.
3. Run `show <id>` only for items being actively discussed.
4. After an item is resolved, run `done <id>`.

**User asks "what's left?":**

1. Run `list --project <name>` and present the output directly.
