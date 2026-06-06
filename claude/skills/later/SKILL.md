---
name: later
description: Log and track items to come back to later — bugs found mid-task, feature ideas, project feedback — using a local SQLite database. Use when the user asks to log, list, view, resolve, or work through items saved for later.
user-invocable: false
---

You have access to a CLI at `~/dotfiles/claude/skills/later/run`.

Run it with:

```
~/dotfiles/claude/skills/later/run <command>
```

## Commands

```
later init
later migrate --project <name>
later add --project <name> --title "..." [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
later list [--project <name>] [--all]
later show <id>
later done <id>
later edit <id> [--title "..."] [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
later projects
```

## Database modes

The CLI supports two database modes, selected automatically:

- **Local** — if a `.later.db` file exists in the current directory, it is used. This file can be committed to git and synced across machines.
- **Global** — fallback to `~/dotfiles/claude/skills/later/feedback.db`, a personal cross-project store (gitignored).

`later init` creates a `.later.db` in the current directory, opting the project into local mode.

## Rules

**Ask the user about database mode at the start of each session.** Before running any command for the first time, ask: "Do you want to use the global database (personal, cross-project) or a local `.later.db` in this repository (committable, synced across machines)?" If they say local and no `.later.db` exists in the CWD, run `later init` first.

**Always `list` before `show`.** The list command returns only titles and IDs — it is token-efficient. Only call `show <id>` when you need the full detail of a specific item.

**Default is open items only.** `list` excludes done items unless `--all` is passed. This is correct behaviour — do not add `--all` unless the user specifically asks to see completed items.

**Always pass `--project`.** Infer the project name from the current working directory or from context the user has provided. If ambiguous, ask the user before running any command.

**Priorities:** `high` for bugs or blockers, `medium` for improvements (default), `low` for nice-to-haves.

**Statuses:** `open` (default), `in-progress`, `blocked`, `done`. Use `done <id>` or `edit <id> --status done` to close items. The `list` command excludes `done` items unless `--all` is passed.

**Categories:** Free-text tag (e.g. `bug`, `ux`, `performance`, `gameplay`). Shown in list output as `{category}`.

## Typical flows

**Logging something to come back to:**

1. Ask the user about database mode (global vs local) if not already established this session.
2. If local mode and no `.later.db` exists, run `later init`.
3. Run `list --project <name>` to retrieve open items.
4. Scan the titles for any that overlap with or closely resemble the item(s) the user wants to log.
5. If you spot a potential duplicate or near-duplicate, call `show <id>` on the overlapping item, then present your findings to the user and ask: "This looks similar to #<id> — do you want to update that existing item or log a new one?"
6. Only proceed with `add` once the user has confirmed there is no overlap, or has explicitly asked for a new item.
7. Confirm how many items were added or updated.

**Working through items:**

1. Run `list --project <name>` to get open items.
2. Present the titles to the user and ask which to tackle.
3. Run `show <id>` only for items being actively discussed.
4. After an item is resolved, run `done <id>`.

**User wants to move a project from global to local:**

1. If no `.later.db` exists in the CWD, run `later init`.
2. Run `later migrate --project <name>`. This moves all items for that project out of the global database and into `.later.db`, then deletes them from the global database.
3. Remind the user to commit `.later.db` to git so it syncs across machines.

**User asks "what's left?":**

1. Run `list --project <name>` and present the output directly.
