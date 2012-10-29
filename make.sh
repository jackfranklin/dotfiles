#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 

#zsh
ln -s $dir/.zsh ~/.zsh
ln -s $dir/.zshenv ~/.zshenv
ln -s $dir/.zshrc ~/.zshrc

echo "Symlinked Yo"
