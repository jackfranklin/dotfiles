---
name: later
description: Log and track items to come back to later — bugs found mid-task, feature ideas, project feedback — using a local JSON file. Use when the user asks to log, list, view, resolve, or work through items saved for later.
user-invocable: true
---

You have access to a CLI at `~/dotfiles/claude/skills/later/run`.

Run it with:

```
~/dotfiles/claude/skills/later/run <command> --dir <absolute-path-to-project>
```

**IMPORTANT:** Always pass `--dir` with an absolute path to the project directory. This is how the CLI finds the project's `.later.json`. Omitting it falls back to CWD, which is unreliable in AI contexts and will produce a clear error if run from the home or skill directory.

```
~/dotfiles/claude/skills/later/run list --project routemaster --dir /home/jack/git/routemaster
```

## Commands

```
later init --dir <path>
later add --dir <path> --project <name> --title "..." [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
later list --dir <path> [--project <name>] [--all]
later show <id> --dir <path>
later done <id> --dir <path>
later edit <id> --dir <path> [--title "..."] [--detail "..."] [--priority low|medium|high] [--status open|in-progress|blocked|done] [--category "..."]
later projects --dir <path>
later archive --dir <path>
later migrate --dir <path>
```

## Storage

Each project stores its items in a `.later.json` file in the project root. This file is plain JSON, human-readable, git-diffable, and can be committed to git and synced across machines without binary conflicts.

`later init --dir <path>` creates an empty `.later.json` in the given directory.

`later archive --dir <path>` removes all done items from `.later.json` and appends them to `.later.archive.json`, keeping the active file small. Run periodically to keep the file tidy.

`later migrate --dir <path>` converts a legacy `.later.db` SQLite file to `.later.json`. After running, delete `.later.db` and commit `.later.json`.

## Rules

**Always pass `--dir <absolute-path>`.** Derive the path from the primary working directory the user is in. Never omit it.

**Always `list` before `show`.** The list command returns only titles and IDs — it is token-efficient. Only call `show <id>` when you need the full detail of a specific item.

**Default is open items only.** `list` excludes done items unless `--all` is passed. This is correct behaviour — do not add `--all` unless the user specifically asks to see completed items.

**Always pass `--project`.** Infer the project name from the current working directory or from context the user has provided. If ambiguous, ask the user before running any command.

**Priorities:** `high` for bugs or blockers, `medium` for improvements (default), `low` for nice-to-haves.

**Statuses:** `open` (default), `in-progress`, `blocked`, `done`. Use `done <id>` or `edit <id> --status done` to close items. The `list` command excludes `done` items unless `--all` is passed.

**Categories:** Free-text tag (e.g. `bug`, `ux`, `performance`, `gameplay`). Shown in list output as `{category}`.

## Typical flows

**Logging something to come back to:**

1. Run `list --project <name> --dir <path>` to retrieve open items.
2. Scan the titles for any that overlap with or closely resemble the item(s) the user wants to log.
3. If you spot a potential duplicate or near-duplicate, call `show <id> --dir <path>` on the overlapping item, then present your findings to the user and ask: "This looks similar to #<id> — do you want to update that existing item or log a new one?"
4. Only proceed with `add` once the user has confirmed there is no overlap, or has explicitly asked for a new item.
5. Confirm how many items were added or updated.

**Working through items:**

1. Run `list --project <name> --dir <path>` to get open items.
2. Present the titles to the user and ask which to tackle.
3. Run `show <id> --dir <path>` only for items being actively discussed.
4. After an item is resolved, run `done <id> --dir <path>`.

**User asks "what's left?":**

1. Run `list --project <name> --dir <path>` and present the output directly.

**No .later.json exists yet — check for .later.db first:**

1. Check whether a `.later.db` file exists in the project directory.
2. If it does: run `later migrate --dir <path>`, then delete `.later.db` and remind the user to commit `.later.json`.
3. If it does not: run `later init --dir <path>` and remind the user to commit `.later.json` to git.
