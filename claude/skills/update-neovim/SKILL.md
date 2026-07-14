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

1. **Analyze and Check Installation**: Run the update script with the `--check` flag to investigate the environment:
   ```bash
   bash ~/dotfiles/nvim/lua/upstream-dotfiles/claude/skills/update-neovim/scripts/update-neovim.sh --check
   ```
2. **Review and Confirm**:
   - Inspect the output of the check.
   - Formulate a clear plan explaining what type of installation was detected, where it resides, and what action the script will perform.
   - Present this plan to the user in the chat and ask for confirmation:
     *"I detected a [standalone/AppImage extract] installation at [path]. I plan to [update/fresh install] it from version [current] to [latest] by [method]. Do you want to proceed?"*
   - Stop and wait for their explicit approval.
3. **Execute Update**:
   - Once approved, run the update script without flags:
     ```bash
     bash ~/dotfiles/nvim/lua/upstream-dotfiles/claude/skills/update-neovim/scripts/update-neovim.sh
     ```
4. **Verify Success**: Output the results and confirm with `nvim --version`.
