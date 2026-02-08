# gwn - Git Worktree New
#
# Creates a new git worktree in a sibling directory with a new branch of the same name.
#
# Usage:
#   gwn <name>
#
# Arguments:
#   name - The name for both the worktree directory and the new branch
#
# Example:
#   gwn feature-auth
#   # Creates ../feature-auth/ directory
#   # Creates and checks out new branch 'feature-auth'
#
# The worktree is created as a sibling to the current repository root,
# making it easy to switch between worktrees with cd ../other-branch.
#
# See also:
#   gwl - List all worktrees
#   gwj - Jump to a worktree interactively
#   gwd - Delete a worktree and its branch

function gwn --description "Create a new git worktree with a new branch"
    if test (count $argv) -eq 0
        echo "Usage: gwn <name>"
        echo ""
        echo "Creates a new worktree at ../<name> with a new branch called <name>"
        return 1
    end

    set -l name $argv[1]
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "Error: Not in a git repository"
        return 1
    end

    set -l worktree_path (dirname $repo_root)/$name

    if test -d $worktree_path
        echo "Error: Directory already exists: $worktree_path"
        return 1
    end

    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/$name
        echo "Error: Branch '$name' already exists"
        echo "Hint: Use 'git worktree add $worktree_path $name' to create a worktree for an existing branch"
        return 1
    end

    git worktree add -b $name $worktree_path

    if test $status -eq 0
        echo ""
        echo "Created worktree at: $worktree_path"
        echo "On new branch: $name"
        echo ""
        echo "To switch to it: cd $worktree_path"
    end
end
