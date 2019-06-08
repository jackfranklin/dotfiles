# Jack's Dotfiles

My dotfiles for Vim and ZSH. Shamelessly stolen from tonnes of dotfile repositories I found online.

Files are symlinked into the proper location, and have the `.` added. For example:

```
~/dotfiles/vim/vim => ~/.vim
~/dotfiles/vim/vimrc => ~/.vimrc
~/dotfiles/zsh/zshrc => ~/.zshrc
~/dotfiles/git/gitignore_global => ~/.gitignore_global
...and so on
```
# Vim Plugins

Are all handled with Vim Plug.

# Setting up the ergodox keyboards

- Latest ergodox layout: https://configure.ergodox-ez.com/ergodox-ez/layouts/EeKGv/latest/1

# Mac Apps

Most should be installed with the Brewfile, which you can install with `make install_brews`

# Authentication

- `npm adduser` to login to npm
- Generate a new token for Github and use that to authenticate with `hub`

