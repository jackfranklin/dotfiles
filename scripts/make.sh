#!/bin/bash

########## Variables

dir=$(pwd) # dotfiles directory

echo "Brewing"
ruby $dir/scripts/brewery.rb

echo "Updating bundles"
ruby $dir/scripts/vim_bundles.rb $1

echo "~~~~~~~~~~~~~~~~~"
echo "Symlinking"

#symlinks
#zsh
echo "Symlinking ZSH"
ln -nsf $dir/zsh/.zsh ~/.zsh
ln -sf $dir/zsh/.zshenv ~/.zshenv
ln -sf $dir/zsh/.zshrc ~/.zshrc

#vim
echo "Symlinking Vim"
ln -nsf $dir/vim/.vim ~/.vim
ln -sf $dir/vim/.vimrc ~/.vimrc

#tmux
echo "Symlinking tmux"
ln -sf $dir/tmux/.tmux.conf ~/.tmux.conf

#git
echo "Symlinking git"
ln -sf $dir/git/.gitconfig ~/.gitconfig
ln -sf $dir/git/.gitignore_global ~/.gitignore_global

#bin
echo "Symlinking tmux-vim-select-pane to /usr/bin"
sudo ln -sf $dir/bin/tmux-vim-select-pane /usr/bin/tmux-vim-select-pane

echo "~~~~~~~~~~~~~~~~~"
echo "All done"

