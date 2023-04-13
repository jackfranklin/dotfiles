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

# $PATH
# Note that fish_add_path prepends by default, so the -a flag is used to
# signify amend, so that the order the lines are here is the order that they
# are in the $PATH
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.fzf/bin
fish_add_path $HOME/git/private-dotfiles/bin
fish_add_path (npm get prefix)/bin
fish_add_path $HOME/.local/bin
# For computers where I build Neovim from source.
fish_add_path $HOME/neovim/bin
# Installing neovim via the appimage + extracting it
fish_add_path $HOME/squashfs-root/usr/bin
# (Now deprecated) installing Neovim via a tarball
# fish_add_path $HOME/nvim-linux64/bin

if type -q "setxkbmap"
  # Remaps caps-lock to escape.
  setxkbmap -option caps:escape
end
