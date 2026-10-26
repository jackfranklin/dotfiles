# Global Agent Instructions

## Skills and subagents

Custom skills and subagents are shared between Claude Code and Pi. Their only
sources are `~/dotfiles/agents/skills/<name>/` and
`~/dotfiles/agents/subagents/<name>.md`. The copies in `~/.claude/skills`,
`~/.claude/agents`, `~/.pi/agent/skills` and `~/.pi/agent/agents` are
generated and read-only. To add or change one, edit the source, run
`make -C ~/dotfiles agents`, then reload the harness. Read
`~/dotfiles/agents/README.md` first for the source format and the
`{{#claude}}` / `{{#pi}}` template syntax.

## Operational recipes

When a request matches one of these operations, read its recipe before acting:

- **Convert audio to mono:** read `~/dotfiles/docs/recipes/convert-audio-mono.md` and use `~/dotfiles/scripts/convert-audio-mono.sh`.
- **Check Steam startup/update status:** read `~/dotfiles/docs/recipes/steam-status.md` and use `~/dotfiles/scripts/steam-status.sh`.
- **Update Neovim:** read `~/dotfiles/docs/recipes/update-neovim.md`; run its `--check` command, explain the plan, and obtain explicit confirmation before running the update.
