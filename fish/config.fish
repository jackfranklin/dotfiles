alias ga="git add"
alias gaa="git aa"
alias gap="git add -p"
alias gci="git ci"
alias gco="git co"
alias gcom="git co master"
alias gcob="git co -b"
alias gd="git diff"
alias gds="git diff --staged"
alias gpu="git push"
alias grm="git rm"
alias grh="git reset HEAD"
alias gput="git push --tags"
alias gpl="git pull"
alias gt="git tag"
alias gl="git log"
alias gnrt="git-new-remote-tracking"
alias hpr="hub pull-request"
alias hb="hub browse"
alias hc="hub compare"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gsp="git stash pop"
alias gconflict="git diff --name-only --diff-filter=U"
alias df="cd ~/dotfiles"

set EDITOR 'nvim'

set -x FZF_DEFAULT_COMMAND 'ag -g "" --hidden --ignore .git'
set -gx TERM alacritty;


source ~/.asdf/asdf.fish

set -g fisher_path $HOME/dotfiles/fish/fisher_files

set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..-1]
set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..-1]

for file in $fisher_path/conf.d/*.fish
  builtin source $file 2> /dev/null
end

set fish_greeting
contains $HOME/git/private-dotfiles/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/git/private-dotfiles/bin
contains $HOME/neovim/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/neovim/bin

contains (npm get prefix)/bin $fish_user_paths; or set -Ua fish_user_paths (npm get prefix)/bin
contains $HOME/.local/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/.local/bin
contains $HOME/git/lua-language-server/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/git/lua-language-server/bin

# Note the -p here means prepend, so that the cargo stuff is used ahead of any other sources for Rust things
contains $HOME/.cargo/bin $fish_user_paths; or set -Up fish_user_paths $HOME/.cargo/bin

if type -q "setxkbmap"
  # Remaps caps-lock to escape.
  setxkbmap -option caps:escape
end
