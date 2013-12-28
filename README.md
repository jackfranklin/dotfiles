#Jack's Dotfiles

My dotfiles for Vim and ZSH. Shamelessly stolen from tonnes of dotfile repositories I found online.

Files are symlinked into the proper location, and have the `.` added. For example:

```
~/dotfiles/vim/vim => ~/.vim
~/dotfiles/vim/vimrc => ~/.vimrc
~/dotfiles/zsh/zshrc => ~/.zshrc
~/dotfiles/git/gitignore_global => ~/.gitignore_global
...and so on
```

# Installing

- Clone repository (I recommend `~/dotfiles`)
- `cd ~/dotfiles`
- `make`

# Adding new vim plugin
- plugins are managed in `vim/vimrc` with [Vundle](https://github.com/gmarik/vundle). Add a plugin there, restart Vim and run `:BundleInstall`.

# homebrew
- Add line to `Brewfile`.
- Run `make brew`

# node & npm
- The latest Node is installed via homebrew.
- packages are managed in `scripts/npm_bundles.rb`. Add a new package, and run `make node`.

# gems
- Add gem to `scripts/gems.rb`
- `make gems`


# Updating
You can run `make` at any time to keep things nice and tidy.

# Requirements

You'll need Ruby and Git installed initially, to first clone this repo and then to run `./scripts/make.sh` (which in turn calls various Ruby & Sh files. Once that's done, you'll have Ruby properly setup through `rbenv` and the latest Git installed also through homebrew, but you'll need some version of Ruby & Git to get started.

These dotfiles should be fairly agnostic about the OS and environment, but be aware this has only been tested on my machines (Mac, OS X Lion).

