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

## Windows & WSL
- Install Windows Terminal experimental (currently need the new text rendering engine with better cursor colour contrast)
- Add Catpuccin theme for Win terminal + enable. Set Ubuntu as the default profile when opening the terminal / new tab.

## Building nvim

1. Clone nvim to `~/git/neovim`.
1. `git pull` if required on `master.`
1. `git checkout <tag>` if you want a stable version.
1. Build with the right flags:
    ```
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim
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

## Setting up Alacritty
- Install latest version from GitHub
- [WINDOWS] `make sync_alacritty_windows` to copy the config into the right place
- Ensure `alacritty.info` is installed properly [https://github.com/alacritty/alacritty/blob/master/INSTALL.md#terminfo]. Note that you can drop the `sudo` from the command (at least for me).
- Make sure `echo $TERM` gives you `alacritty`, and `infocmp alacritty` works.
- Check it is all configured with the right fonts by running `echo -e "\e[3mItalic"` and seeing if it outputs italic.

## Fonts

Fonts I have purchased are all in the `Purchased Fonts` folder of Google Drive (do not put them into the repo or public!).

## Lua LS

Install the release from GitHub and then create the wrapper script and put it on the PATH:

```
https://github.com/luals/lua-language-server/wiki/Getting-Started#command-line
```

## Setting up Lua things

- Install `lua5.1` and `lua5.1-dev` from apt-get. Need them both so LuaRocks can install.
- Install LuaRocks: https://luarocks.org/#quick-start

## Slow performance on large TS files

Seems to be an nvim-treesitter issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/3581.
Even though that is marked as closed, it still causes me issues. The fix is to manually go into the nvim-treesitter install (.local/share/nvim/site/pack...) and comment out the injection that is mentioned in the opening post on that GH issue:
```
((comment) @_gql_comment
  (#eq? @_gql_comment "/* GraphQL */")
  (template_string) @graphql)
```
That makes it snappy on the larger files again.

**Update** on 19th April 2023: [this commit](https://github.com/nvim-treesitter/nvim-treesitter/commit/da7f886ab5dde87b7c9bbae1c1eb99aa63a74e55) to nvim-treesitter has updated the above injection and it seems much quicker now. So likely do not need to do this change by default.

## Treesitter errors

If random errors are seen during syntax highlighting, it might be that the Treesitter parsers are not up to date with the version of Treesitter.

To fix, load up NeoVim and run `:TSUpdate` to force them to be updated. See https://github.com/nvim-treesitter/nvim-treesitter/issues/3092 for more.

## Installing `fd`

Installing `fd` swaps fzf-lua to use it and it is a bit snappier than the find command.

- Ubuntu install: https://github.com/sharkdp/fd#on-ubuntu
- Mac install: https://github.com/sharkdp/fd#on-macos

