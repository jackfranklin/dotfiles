# gwd - Git Worktree Delete
#
# Deletes a git worktree and its associated branch.
#
# Usage:
#   gwd <name> [options]
#
# Arguments:
#   name - The name of the worktree/branch to delete
#
# Options:
#   --force, -f   Skip confirmation prompt
#   --remote, -r  Also delete the remote tracking branch (origin/<name>)
#
# Examples:
#   gwd feature-auth
#   # Prompts for confirmation, then removes ../feature-auth/ and deletes branch
#
#   gwd feature-auth --force
#   # Removes without confirmation
#
#   gwd feature-auth --remote
#   # Also runs: git push origin --delete feature-auth
#
#   gwd feature-auth --force --remote
#   # Does everything without confirmation
#
# Safety:
#   - By default, requires confirmation before deleting
#   - Will warn if the worktree has uncommitted changes
#   - Remote branch deletion is opt-in via --remote flag
#
# See also:
#   gwn - Create a new worktree
#   gwl - List all worktrees
#   gwj - Jump to a worktree interactively

function gwd --description "Delete a git worktree and its branch"
    argparse 'f/force' 'r/remote' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: gwd <name> [--force] [--remote]"
        echo ""
        echo "Deletes the worktree at ../<name> and the branch <name>"
        echo ""
        echo "Options:"
        echo "  --force, -f   Skip confirmation prompt"
        echo "  --remote, -r  Also delete the remote branch"
        return 1
    end

    set -l name $argv[1]
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    set -l worktree_path (dirname $repo_root)/$name

    # Check if worktree exists
    if not test -d $worktree_path
        echo "Error: Worktree directory does not exist: $worktree_path"
        return 1
    end

    # Verify it's actually a worktree
    if not git worktree list | grep -q "^$worktree_path "
        echo "Error: $worktree_path is not a git worktree"
        return 1
    end

    # Check if we're currently in the worktree we're trying to delete
    set -l current_dir (pwd)
    if string match -q "$worktree_path*" $current_dir
        echo "Error: Cannot delete the worktree you are currently in"
        echo "Hint: cd to another worktree first (try 'gwj')"
        return 1
    end

    # Confirmation prompt unless --force
    if not set -q _flag_force
        echo "This will delete:"
        echo "  Worktree: $worktree_path"
        echo "  Branch:   $name"
        if set -q _flag_remote
            echo "  Remote:   origin/$name"
        end
        echo ""
        read -l -P "Are you sure? [y/N] " confirm
        if not string match -qi 'y' $confirm
            echo "Cancelled"
            return 0
        end
    end

    # Remove the worktree
    echo "Removing worktree..."
    git worktree remove $worktree_path
    if test $status -ne 0
        echo "Error: Failed to remove worktree"
        echo "Hint: Use 'git worktree remove --force $worktree_path' if it has uncommitted changes"
        return 1
    end

    # Delete the local branch
    echo "Deleting local branch..."
    git branch -d $name 2>/dev/null
    if test $status -ne 0
        # Try force delete if normal delete fails (unmerged branch)
        echo "Branch has unmerged changes. Force deleting..."
        git branch -D $name
        if test $status -ne 0
            echo "Warning: Could not delete branch '$name'"
        end
    end

    # Delete remote branch if --remote flag is set
    if set -q _flag_remote
        echo "Deleting remote branch..."
        git push origin --delete $name 2>/dev/null
        if test $status -ne 0
            echo "Warning: Could not delete remote branch 'origin/$name'"
            echo "It may not exist or you may not have permission"
        end
    end

    echo ""
    echo "Done. Deleted worktree and branch: $name"
end
