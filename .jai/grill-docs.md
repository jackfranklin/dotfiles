# Grill Docs — Skills GitHub Migration

## Decisions

### Storage: GitHub Issues (per-repo)
All persistent skill output (plans, handoffs, backlog items) lives in GitHub Issues on the repo being worked in. No central repo. Skills error if there is no GitHub remote.

### Legacy `.jai/` folder
Clean break — no fallback. Skills search GitHub only. Old `.jai/` files can be migrated manually if needed.

### `later` skill
Retired the Deno/SQLite CLI (`~/dotfiles/claude/skills/later/run`) and `.later.json` format entirely. The skill is now a thin wrapper: run `gh issue create` in the current repo. No prefix on issue title — a `later` item is just a regular GitHub Issue. Error if no GitHub remote exists.

### Title prefixes
- `[PLAN]` — detailed implementation plans (from `write-plan`)
- `[HANDOFF]` — conversation state / session handoffs (from `handoff`)
- No prefix — backlog/todo items (from `later`)

### Temp files (`review-plan`)
Use `/tmp/plan-<timestamp>.md` instead of `.jai/tmp/`. No directory creation needed.

### `bug-report` skill
Unchanged — stays as a pure formatting skill (display in chat only, no GitHub integration). Reason: also used in non-GitHub work environments.

### Plans in GitHub Issues
Full plan content goes in the Issue body. 65k char limit is sufficient; a plan that exceeds it should be split into sub-tasks.
