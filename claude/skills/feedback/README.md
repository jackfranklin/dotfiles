# feedback

A personal CLI for tracking feedback and bugs across projects, backed by SQLite. Designed to be used as a Claude skill so Claude can log and work through feedback token-efficiently — only titles are loaded until detail is needed.

## Usage

```
~/dotfiles/claude/skills/feedback/run <command>
```

`run` is a thin wrapper that passes the required Deno permission flags automatically. On first run, Deno will download the SQLite native library and cache it. Subsequent runs are instant.

## Commands

| Command | Description |
|---|---|
| `add --project <p> --title <t> [--detail <d>] [--priority low\|medium\|high]` | Add a feedback item |
| `list [--project <p>] [--all]` | List open items (titles + IDs only) |
| `show <id>` | Show full detail for one item |
| `done <id>` | Mark an item as done |
| `edit <id> [--title <t>] [--detail <d>] [--priority <p>]` | Edit an item |
| `projects` | List all project names |

`list` defaults to open items only. Pass `--all` to include done items.

## Database

The database lives at `claude/skills/feedback/feedback.db` and is gitignored. It is created automatically on first run.

## Claude skill

The skill at `claude/skills/feedback/SKILL.md` teaches Claude to use this tool automatically. Claude will call `list` first to get titles, then `show <id>` only for items it needs detail on — keeping token usage low as the list grows.
