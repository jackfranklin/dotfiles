# gwl - Git Worktree List
#
# Lists all git worktrees for the current repository.
#
# Usage:
#   gwl
#
# Output shows each worktree with:
#   - Full path to the worktree directory
#   - HEAD commit (short hash)
#   - Branch name (or detached HEAD state)
#
# Example output:
#   /home/user/project        abc1234 [main]
#   /home/user/project-feature def5678 [feature-auth]
#
# See also:
#   gwn - Create a new worktree
#   gwj - Jump to a worktree interactively
#   gwd - Delete a worktree and its branch

function gwl --description "List all git worktrees"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gwl"
        echo ""
        echo "Lists all git worktrees for the current repository."
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Output shows each worktree with:"
        echo "  - Full path to the worktree directory"
        echo "  - HEAD commit (short hash)"
        echo "  - Branch name (or detached HEAD state)"
        return 0
    end

    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    git worktree list
end
