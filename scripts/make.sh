#!/bin/bash

########## Variables

dir=$(pwd) # dotfiles directory

echo "Symlinking ZSH"
ln -nsf $dir/zsh/zsh ~/.zsh
ln -sf $dir/zsh/zshenv ~/.zshenv
ln -sf $dir/zsh/zshrc ~/.zshrc
echo "~~~~~~~~~~~~~~~~~"
echo "Symlinking Vim"
ln -nsf $dir/vim/vim ~/.vim
ln -sf $dir/vim/vimrc ~/.vimrc
echo "~~~~~~~~~~~~~~~~~"
echo "Symlinking tmux"
ln -sf $dir/tmux/tmux.conf ~/.tmux.conf
echo "~~~~~~~~~~~~~~~~~"
echo "Symlinking git"
ln -sf $dir/git/gitconfig ~/.gitconfig
ln -sf $dir/git/gitignore_global ~/.gitignore_global
echo "~~~~~~~~~~~~~~~~~"
sh $dir/scripts/symlinks.sh
echo "~~~~~~~~~~~~~~~~~"

echo "Brewing"
ruby $dir/scripts/brewery.rb
echo "~~~~~~~~~~~~~~~~~"

echo "Setting up npm"
ruby $dir/scripts/npm_bundles.rb $1
echo "~~~~~~~~~~~~~~~~~"

echo "Updating Vim bundles"
ruby $dir/scripts/vim_bundles.rb $1
echo "~~~~~~~~~~~~~~~~~"

echo "Symlinking snippets"
ln -nsf ~/git/vim-snippets ~/.vim/bundle/
echo "~~~~~~~~~~~~~~~~~"


