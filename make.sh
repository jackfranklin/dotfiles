#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$(pwd)                    # dotfiles directory
# change to the dotfiles directory

echo "Updating bundles"
$dir/.vim/update_bundles

echo "Installing Command-T"
cd $dir/.vim/bundle/command-t/ruby/command-t && rbenv local system && ruby extconf.rb && make

echo "Bundles installed"



#symlinks
#zsh
ln -s $dir/.zsh ~/.zsh
ln -s $dir/.zshenv ~/.zshenv
ln -s $dir/.zshrc ~/.zshrc

#vim
ln -s $dir/.vim ~/.vim
ln -s $dir/.vimrc ~/.vimrc
ln -s $dir/.gvimrc ~/.gvimrc

#tmux
ln -s $dir/.tmux.conf ~/.tmux.conf

#pulldown
ln -s $dir/.pulldown.json ~/.pulldown.json

#git
ln -s $dir/.gitconfig ~/.gitconfig
ln -s $dir/.gitignore_global ~/.gitignore_global

echo "Symlinked Yo"
