# gbr - Git Branch (checkout)
#
# Interactively select a local git branch using fzf and check it out.
#
# Usage:
#   gbr
#
# Dependencies:
#   fzf - Command-line fuzzy finder (https://github.com/junegunn/fzf)
#
# Only local branches are listed (no remotes).

function gbr --description "Checkout a local git branch using fzf"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gbr"
        echo ""
        echo "Interactively select a local git branch using fzf and check it out."
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Dependencies:"
        echo "  fzf - Command-line fuzzy finder (https://github.com/junegunn/fzf)"
        return 0
    end

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

    set -l selection (git branch --format="%(refname:short)" | fzf --height=40% --reverse --prompt="Checkout branch: ")

    if test -z "$selection"
        # User cancelled fzf
        return 0
    end

    git checkout $selection
end
