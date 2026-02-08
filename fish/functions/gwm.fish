# gwm - Git Worktree Move
#
# Moves the current branch into a new worktree in a sibling directory.
#
# This is useful when you've started working on a branch in the main checkout
# and want to move it into its own worktree to free up the main checkout.
#
# Usage:
#   gwm
#
# What it does:
#   1. Detects the current branch name
#   2. Stashes any uncommitted changes (if present)
#   3. Detaches HEAD to free the branch
#   4. Creates a new worktree at ../<branch> for the branch
#   5. Restores stashed changes in the new worktree
#   6. Changes directory to the new worktree
#
# Example:
#   (on branch feature-auth with uncommitted changes)
#   gwm
#   # Stashes changes
#   # Detaches HEAD in the original checkout
#   # Creates ../feature-auth/ worktree on branch feature-auth
#   # Pops stash in the new worktree
#   # cd's into ../feature-auth/
#
# Note: You cannot move the main/master branch or a detached HEAD.
#
# See also:
#   gwn - Create a new worktree with a new branch
#   gwj - Jump to a worktree interactively
#   gwl - List all worktrees
#   gwd - Delete a worktree and its branch

function gwm --description "Move current branch into a new worktree"
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    # Get current branch name
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)

    if test -z "$branch"
        echo "Error: HEAD is detached - no branch to move"
        return 1
    end

    set -l worktree_path (dirname $repo_root)/$branch

    if test -d $worktree_path
        echo "Error: Directory already exists: $worktree_path"
        return 1
    end

    # Check if there are uncommitted changes to stash
    set -l has_changes false
    if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
        set has_changes true
    end

    # Also check for untracked files
    if test (git ls-files --others --exclude-standard | count) -gt 0
        set has_changes true
    end

    # Stash changes if needed (include untracked files)
    if test $has_changes = true
        echo "Stashing uncommitted changes..."
        git stash push --include-untracked -m "gwm: moving $branch to worktree"
        if test $status -ne 0
            echo "Error: Failed to stash changes"
            return 1
        end
    end

    # Detach HEAD to free the branch
    echo "Detaching HEAD..."
    git checkout --detach
    if test $status -ne 0
        echo "Error: Failed to detach HEAD"
        # Restore stash if we created one
        if test $has_changes = true
            git stash pop
        end
        return 1
    end

    # Create the worktree
    echo "Creating worktree..."
    git worktree add $worktree_path $branch
    if test $status -ne 0
        echo "Error: Failed to create worktree"
        # Try to recover: go back to the branch
        git checkout $branch
        if test $has_changes = true
            git stash pop
        end
        return 1
    end

    # Pop stash in the new worktree
    if test $has_changes = true
        echo "Restoring changes in new worktree..."
        git -C $worktree_path stash pop
        if test $status -ne 0
            echo "Warning: Failed to pop stash in new worktree"
            echo "Your changes are still in the stash - run 'git stash pop' in the worktree"
        end
    end

    echo ""
    echo "Moved branch '$branch' to worktree: $worktree_path"

    cd $worktree_path
    echo "Switched to: $worktree_path"
end
