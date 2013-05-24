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
ln -nsf $dir/.zsh ~/.zsh
ln -sf $dir/.zshenv ~/.zshenv
ln -sf $dir/.zshrc ~/.zshrc

#vim
echo "Symlinking Vim"
ln -nsf $dir/.vim ~/.vim
ln -sf $dir/.vimrc ~/.vimrc

#tmux
echo "Symlinking tmux"
ln -sf $dir/.tmux.conf ~/.tmux.conf

#git
echo "Symlinking git"
ln -sf $dir/.gitconfig ~/.gitconfig
ln -sf $dir/.gitignore_global ~/.gitignore_global

#bin
echo "Symlinking tmux-vim-select-pane to /usr/bin"
sudo ln -sf $dir/bin/tmux-vim-select-pane /usr/bin/tmux-vim-select-pane

echo "~~~~~~~~~~~~~~~~~"
echo "All done"

