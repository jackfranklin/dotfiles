#Jack's Dotfiles

My dotfiles for Vim and ZSH. Shamelessly stolen from tonnes of dotfile repositories I found online.


# Installing

- Clone repository (I recommend `~/dotfiles`)
- `cd ~/dotfiles`
- `./make.sh NEW`

# Adding new plugin
- Add plugin to `~/dotfiles/.vim/update_bundles`
- Run `./make.sh`

Running `make.sh` without arguments means it will only install new plugins and not do a fresh install of everything. Running it with an argument makes it do an entirely fresh install.

#Plugins

Plugins are all managed with Pathogen, and added to the update_bundles script in `~/dotfiles/.vim/update_bundles`.

# Caveats

The make file is very much set up for my system. When setting up Command-T it presumes rbenv exists.


