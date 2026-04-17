# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for Jack Franklin. Uses a **symlink-based installation** strategy: files are stored in this repo without a leading dot, then symlinked into place with `make <target>`. No `stow` — the Makefile manages all symlinks explicitly.

## Common Commands

```bash
# Run Lua unit tests (requires busted)
make lua_specs

# Install individual tool configs (creates symlinks)
make neovim      # ~/dotfiles/nvim → ~/.config/nvim
make fish        # ~/dotfiles/fish → ~/.config/fish
make git         # gitconfig + gitignore_global → ~/.gitconfig / ~/.gitignore_global
make kitty       # ~/dotfiles/kitty → ~/.config/kitty
make claude      # settings.json + CLAUDE.md + skills → ~/.claude/

# Install system packages (Ubuntu/Debian)
make ubuntu-deps

# Install global npm language servers (TypeScript, Svelte, ESLint, etc.)
make language_servers_global
```

## Architecture

### Installation Model

Each `make` target runs `ln -nsf` to create a symlink. There is no automatic install — targets must be run individually. The `DIR` variable defaults to `~/dotfiles`.

### Neovim (`nvim/`)

All Neovim config is Lua under `nvim/lua/jack/`. Entry point is `nvim/init.lua`.

**Plugin system:** Plugins are declared in `nvim/lua/jack/load_plugins.lua` as a single `base_plugins()` table. `M.load(config)` supports three override keys:
- `extra_plugins` — add plugins not in base
- `config_overrides` — replace a plugin's `config` function by plugin name/dir
- `delete_plugins` — exclude a plugin from loading

This allows `per_machine.lua` to customise plugins without modifying the shared list.

**Plugin configs** live in `nvim/lua/jack/plugins/<plugin-name>.lua` and are `require()`d from the plugin's `config` function.

**LSP setup** (`nvim/lua/jack/lsp-config.lua`) exports per-server setup functions (`M.typescript`, `M.deno`, `M.eslint`, `M.lua`, `M.css`). These must be called explicitly — typically from `nvim/lua/jack/plugins/lsp.lua` or `per_machine.lua`.

**Per-machine config:** `nvim/lua/jack/per_machine.lua` is gitignored. It is `require()`d from `init.lua` and is where machine-specific LSP calls, plugin overrides, and paths go. Same pattern exists for `wezterm/per_machine.lua`.

**Alternate files** (`nvim/lua/jack/alternate-files.lua`): pure Lua module with no Neovim API dependency. Tested with busted (`alternate-files_spec.lua` in the same directory).

### Fish Shell (`fish/`)

Primary shell. Custom functions live in `fish/functions/`. Git workflow shortcuts follow the pattern `gw*` (e.g. `gwm` = go to main, `gwn` = new branch). The `v` function opens Neovim; `ck` and `tj` are project-navigation helpers.

### Claude Integration (`claude/`)

`claude/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md` (global Claude Code instructions, separate from this file). Skills in `claude/skills/` each have a `SKILL.md` manifest. The feedback skill is a Deno + SQLite CLI compiled to a binary.

### Git Config (`git/`)

Notable aliases: `dft`/`dl`/`ds` use difftastic for diffs. `news`/`news-fzf` browse recent commits with FZF previews. `mainormaster` detects the default branch name. Pull strategy is rebase; conflict style is `diff3`.

## Code Formatting

Prettier config (`prettier.config.mjs`): `semi: true`, `trailingComma: "all"`, `singleQuote: true`.

Neovim uses `conform.nvim` for format-on-save. Formatters are configured per filetype in `nvim/lua/jack/plugins/conform-config.lua`.

## Testing

Only `nvim/lua/jack/alternate-files_spec.lua` has automated tests. Run with `make lua_specs` (requires `busted` installed via LuaRocks). There is no CI.
