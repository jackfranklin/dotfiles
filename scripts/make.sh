#!/bin/bash

########## Variables

dir=$(pwd) # dotfiles directory

echo "Symlinking Config Files"
ln -nsf $dir/zsh/zsh ~/.zsh
ln -sf $dir/zsh/zshenv ~/.zshenv
ln -sf $dir/zsh/zshrc ~/.zshrc
ln -nsf $dir/vim/vim ~/.vim
ln -sf $dir/vim/vimrc ~/.vimrc
ln -nsf $dir/vim/plugin ~/.vim/plugin
ln -sf $dir/tmux/tmux.conf ~/.tmux.conf
ln -sf $dir/pow/powconfig ~/.powconfig
ln -sf $dir/git/gitconfig ~/.gitconfig
ln -sf $dir/git/gitignore_global ~/.gitignore_global
ln -sf $dir/ack/ackrc ~/.ackrc
ln -sf $dir/ctags/ctags ~/.ctags
sh $dir/scripts/symlinks.sh
echo "~~~~~~~~~~~~~~~~~"

echo "Setting up Ruby"
ruby $dir/scripts/ruby_env.rb
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
