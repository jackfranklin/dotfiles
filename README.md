# Jack's Dotfiles

My dotfiles for Vim, ZSH, Fish (which I'm trying!) and many other things. Mostly taken from endless googling and reading of other people's dotfiles.

Note that these aren't designed to be droppable onto your machine - lots of stuff is specific to me :)

Files are symlinked into the proper location, and have the `.` added. For example:

```
~/dotfiles/vim/vim => ~/.vim
~/dotfiles/vim/vimrc => ~/.vimrc
~/dotfiles/zsh/zshrc => ~/.zshrc
~/dotfiles/git/gitignore_global => ~/.gitignore_global
...and so on
```

# New machine setup steps

- Download Chrome
- Download 1Password and login
- Generate SSH key and set it up on GitHub
- Clone this repo into `~/dotfiles`
- Setup Vim
  - `make vim`
  - Install neovim from repo https://github.com/neovim/neovim/wiki/Building-Neovim)
  - Install Vim plug (https://github.com/junegunn/vim-plug)
  - Run Vim + plug install
- Install [asdf](https://asdf-vm.com/#/)
  - install `asdf-nodejs`
- Change the default shell to Fish
- `cd fish && make symlink`
- `npm adduser` to login to npm

## Windows & WSL
- Install Windows Terminal experimental (currently need the new text rendering engine with better cursor colour contrast)
- Add Catpuccin theme for Win terminal + enable. Set Ubuntu as the default profile when opening the terminal / new tab.

## Building nvim

1. Clone nvim to `~/git/neovim`.
1. `git pull` if required on `master.`
1. `git checkout <tag>` if you want a stable version.
1. Build with the right flags:
    ```
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim
    ```
1. `make install`


## Fonts and Kitty terminal

To get the MonoLisa font (note: do not commit the font files to this repo, it's a purchased font!) working, we need to (for whatever reason) convince Kitty that all its variants (including italic/script) are monospace.

Install the font (files in Google Drive); on Linux most reliable way is to copy files into `~/.local/share/fonts` and run `fc-cache -r`.

Then create `~/.config/fonts/fonts.conf`:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="scan">
    <test name="family">
        <string>MonoLisa script</string>
    </test>
    <edit name="spacing">
        <int>100</int>
    </edit>
</match>
</fontconfig>
```

The font-family name should be whatever Kitty shows when you run `kitty +list-fonts`.

