#Jack's Dotfiles

My dotfiles for Vim and ZSH. Shamelessly stolen from tonnes of dotfile repositories I found online.

Files are symlinked into the proper location, and have the `.` added. For example:

```
~/dotfiles/vim/vim => ~/.vim
~/dotfiles/vim/vimrc => ~/.vimrc
~/dotfiles/zsh/zshrc => ~/.zshrc
~/dotfiles/git/gitignore_global => ~/.gitignore_global
```

# Installing

- Clone repository (I recommend `~/dotfiles`)
- `cd ~/dotfiles`
- `./scripts/make.sh NEW`

# Adding new vim plugin
- Add plugin to `~/dotfiles/scripts/vim_bundles.rb`
- Run `./scripts/make.sh`

# homebrew
- add brew to `~/dotfiles/scripts/brewery.rb`
- run that file or just run `./scripts/make.sh`

# node & npm
- The latest Node is installed via homebrew.
- The `~/scripts/npm_bundles.rb` script installs `n` (Node version manager), then installs the latest Node through n, and then installs the npm modules defined in that file globally.


# Updating

Running `make.sh` without arguments means it will only install new plugins and not do a fresh install of everything. Running it with an argument makes it do an entirely fresh install.

The installer will also delete plugins that exist as folders but not in the `vim_bundles.rb` file.

# Requirements

You'll need Ruby and Git installed initially, to first clone this repo and then to run `./scripts/make.sh` (which in turn calls various Ruby & Sh files. Once that's done, you'll have Ruby properly setup through `rbenv` and the latest Git installed also through homebrew, but you'll need some version of Ruby & Git to get started.

These dotfiles should be fairly agnostic about the OS and environment, but be aware this has only been tested on my machines (Mac, OS X Lion).

