#!/bin/bash

########## Variables

dir=$(pwd) # dotfiles directory

echo "Updating bundles"
$dir/.vim/update_bundles $1

echo "Installing Command-T (rbenv presumed)"
cd $dir/.vim/bundle/command-t/ruby/command-t && rbenv local system && ruby extconf.rb && make

echo "Bundles installed"
echo "Symlinking"

#symlinks
#zsh
echo "Symlinking ZSH"
ln -s $dir/.zsh ~/.zsh
ln -s $dir/.zshenv ~/.zshenv
ln -s $dir/.zshrc ~/.zshrc

#vim
echo "Symlinking Vim"
ln -s $dir/.vim ~/.vim
ln -s $dir/.vimrc ~/.vimrc
ln -s $dir/.gvimrc ~/.gvimrc

#tmux
echo "Symlinking tmux"
ln -s $dir/.tmux.conf ~/.tmux.conf

#pulldown
echo "Symlinking pulldown"
ln -s $dir/.pulldown.json ~/.pulldown.json

#git
echo "Symlinking git"
ln -s $dir/.gitconfig ~/.gitconfig
ln -s $dir/.gitignore_global ~/.gitignore_global

#bin
echo "Symlinking tmux-vim-select-pane to /usr/bin"
ln -s $dir/tmux-vim-select-pane /usr/bin/tmux-vim-select-pane

echo "All done"

