# gwj - Git Worktree Jump
#
# Interactively select a worktree using fzf and cd into it.
#
# Usage:
#   gwj
#
# Dependencies:
#   fzf - Command-line fuzzy finder (https://github.com/junegunn/fzf)
#
# The picker displays all worktrees with their paths and current branches.
# Select one to immediately change directory to that worktree.
#
# Note: This function changes the current directory, so it must be a function
# (not a script) to affect the parent shell.
#
# See also:
#   gwn - Create a new worktree
#   gwl - List all worktrees
#   gwd - Delete a worktree and its branch

function gwj --description "Jump to a git worktree using fzf"
    if not command -q fzf
        echo "Error: fzf is required but not installed"
        echo "Install it with your package manager, e.g.:"
        echo "  brew install fzf"
        echo "  apt install fzf"
        return 1
    end

    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get worktree list, extract paths, and pipe to fzf
    set -l selection (git worktree list | fzf --height=40% --reverse --prompt="Jump to worktree: ")

    if test -z "$selection"
        # User cancelled fzf
        return 0
    end

    # Extract the path (first column) from the selection
    set -l worktree_path (echo $selection | awk '{print $1}')

    if test -d $worktree_path
        cd $worktree_path
        echo "Switched to: $worktree_path"
    else
        echo "Error: Directory does not exist: $worktree_path"
        return 1
    end
end
