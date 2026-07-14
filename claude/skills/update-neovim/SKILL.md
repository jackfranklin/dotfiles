---
name: update-neovim
description: Use when the user requests to update, upgrade, or install the latest release of Neovim.
---

# Update Neovim Skill

This skill allows the agent to update Neovim to the latest GitHub release.

## When to Use

- The user wants to update or upgrade Neovim.
- Neovim is outdated, or a specific new version/release of Neovim is needed.

## Core Pattern

1. **Verify environment**: Neovim on this system is installed under `${HOME}/nvim-github-releases/nvim-<os>-<arch>/bin/nvim`.
2. **Execute update script**: Run the update script located in the skill's directory:
   ```bash
   bash ~/dotfiles/nvim/lua/upstream-dotfiles/claude/skills/update-neovim/scripts/update-neovim.sh
   ```
3. **Verify success**: Output the result of the update script and confirm with `nvim --version`.
