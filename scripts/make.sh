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


echo "~~~~~~~~~~~~~~~~~"
#vim
echo "Symlinking Vim"
ln -nsf $dir/vim/.vim ~/.vim
ln -sf $dir/vim/.vimrc ~/.vimrc


echo "~~~~~~~~~~~~~~~~~"
#tmux
echo "Symlinking tmux"
ln -sf $dir/tmux/.tmux.conf ~/.tmux.conf


echo "~~~~~~~~~~~~~~~~~"
#git
echo "Symlinking git"
ln -sf $dir/git/.gitconfig ~/.gitconfig
ln -sf $dir/git/.gitignore_global ~/.gitignore_global


echo "~~~~~~~~~~~~~~~~~"
#bin
sh $dir/scripts/symlinks.sh

echo "~~~~~~~~~~~~~~~~~"
echo "All done"

