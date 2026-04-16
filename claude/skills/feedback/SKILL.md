---
name: feedback
description: Manage feedback and bug reports for a project using a local SQLite database. Use when the user asks to log, list, view, resolve, or work through feedback items or bugs.
user-invocable: false
---

You have access to a feedback tracking CLI at `~/dotfiles/claude/skills/feedback/cli.ts`.

Run it with:
```
deno run --allow-read --allow-write --allow-env --allow-net --allow-ffi ~/dotfiles/claude/skills/feedback/cli.ts <command>
```

## Commands

```
cli.ts add --project <name> --title "..." [--detail "..."] [--priority low|medium|high]
cli.ts list [--project <name>] [--all]
cli.ts show <id>
cli.ts done <id>
cli.ts edit <id> [--title "..."] [--detail "..."] [--priority low|medium|high]
cli.ts projects
```

## Rules

**Always `list` before `show`.** The list command returns only titles and IDs — it is token-efficient. Only call `show <id>` when you need the full detail of a specific item.

**Default is open items only.** `list` excludes done items unless `--all` is passed. This is correct behaviour — do not add `--all` unless the user specifically asks to see completed items.

**Always pass `--project`.** Infer the project name from the current working directory or from context the user has provided. If ambiguous, ask the user before running any command.

**Priorities:** `high` for bugs or blockers, `medium` for improvements (default), `low` for nice-to-haves.

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
