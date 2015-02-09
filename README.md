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
# Credit

Most of the ZSH prompt was taken from: http://www.anishathalye.com/2015/02/07/an-asynchronous-shell-prompt/

# Installing

- Swap your shell to ZSH (System Prefs -> Users -> Right Click on 'Advanced Settings' -> select ZSH from dropdown).
- Clone repository (I recommend `~/dotfiles`). If you don't use `~/dotfiles`, you'll have to update a couple of the scripts to point them to the right place.
- `cd ~/dotfiles`
- Install Node from [NodeJS.org](http://nodejs.org/). (The brew install causes problems with its different paths for node module installs, and it's easier to suck it up and install this way).
- `make`
- That will set up everything, but you'll need to install the Vim plugins. Load up vim (you'll get some errors the first time, ignore them) and run `:BundleInstall`. Once that's done, restart Vim and you're all set to code.

# Adding new vim plugin
- plugins are managed in `vim/vimrc` with [Vundle](https://github.com/gmarik/vundle). Add a plugin there, restart Vim and run `:BundleInstall`.

# homebrew
- Add line to `Brewfile`.
- Run `make brew`

# node & npm
- Node is installed via the installer on nodejs.org.
- packages are managed in `scripts/npm_bundles.rb`. Add a new package, and run `make node`.

# gems
- Add gem to `scripts/gems.rb`
- `make gems`

# Updating
You can run `make` at any time to keep things nice and tidy.

# Requirements

You'll need Ruby and Git installed initially, to first clone this repo and then to run `./scripts/make.sh` (which in turn calls various Ruby & Sh files. Once that's done, you'll have Ruby properly setup through `rbenv` and the latest Git installed also through homebrew, but you'll need some version of Ruby & Git to get started.

These dotfiles should be fairly agnostic about the OS and environment, but be aware this has only been tested on my machines (Mac, OS X Lion).

