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
- `make`
- That will set up everything, but you'll need to install the Vim plugins. Load up vim (you'll get some errors the first time, ignore them) and run `:PlugInstall`. Once that's done, restart Vim and you're all set to code.

# Adding new vim plugin
- plugins are managed in `vim/vimrc` with [Vundle](https://github.com/gmarik/vundle). Add a plugin there, restart Vim and run `:PlugInstall`.
