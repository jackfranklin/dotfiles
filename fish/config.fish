# git add all
alias gaa="git add --all"
# git add by patch
alias gap="git add -p"
# git checkout
alias gco="git checkout"
# git checkout new branch
alias gcob="git co -b"
alias gd="git diff"
# staged diff
alias gds="git diff --staged"
alias gpu="git push"
alias grm="git rm"
alias grh="git reset HEAD"
# git push tags
alias gput="git push --tags"
alias gpl="git pull"
alias gl="git log"
# amend last commit
alias gca="git commit --amend"
# amend last commit with no edit
alias gcan="git commit --amend --no-edit"
# list conflicting files
alias gconflict="git diff --name-only --diff-filter=U"
alias df="cd ~/dotfiles"

set EDITOR 'nvim'

set -x FZF_DEFAULT_COMMAND 'ag -g "" --hidden --ignore .git'


source ~/.asdf/asdf.fish
source $HOME/dotfiles/fish/secrets.fish

# set -g fisher_path $HOME/dotfiles/fish/fisher_files

# set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..-1]
# set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..-1]

# for file in $fisher_path/conf.d/*.fish
#   builtin source $file 2> /dev/null
# end

fish_config theme choose "Catppuccin Frappe"

set fish_greeting

# $PATH
# Note that fish_add_path prepends by default, use -a flag to --amend
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.fzf/bin
fish_add_path $HOME/git/private-dotfiles/bin
fish_add_path (npm get prefix)/bin
fish_add_path $HOME/.local/bin
# For Lua Language server
fish_add_path $HOME/.local/bin/lua-ls/bin
# For computers where I build Neovim from source.
fish_add_path $HOME/neovim/bin
# Installing neovim via the appimage + extracting it
fish_add_path $HOME/squashfs-root/usr/bin
# (Now deprecated) installing Neovim via a tarball
# fish_add_path $HOME/nvim-linux64/bin
fish_add_path $HOME/cargo/bin
# Lua language server from release tar
fish_add_path $HOME/lua-language-server/bin

if type -q "setxkbmap"
  # Remaps caps-lock to escape.
  setxkbmap -option caps:escape
end
