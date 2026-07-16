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

## Pi

Pi config is installed via `make pi` (symlinks `settings.json`, `extensions/`, and `permissions.json`).

Some extensions need npm dependencies; install them with:

```
make pi_deps
```

The `web_search` extension requires an Exa API key. Create one at <https://dashboard.exa.ai/api-keys>, then configure it with `EXA_API_KEY`, or copy `pi/extensions/web-search/auth.example.json` to `auth.json` and fill it in.

### Skill metrics

The `skill-metrics` extension records explicit `/skill:<name>` invocations. Metrics are stored outside this repository in `~/.pi/agent/skill-metrics.sqlite`, keyed by the absolute working directory and skill name. The database and its table are created automatically when Pi loads the extension.

Use `/skill-metrics` to see counts for the current project, or `/skill-metrics all` to see every project.

## Claude / MCP servers

Claude config is installed via `make claude` (symlinks `settings.json`, `CLAUDE.md`, and `skills/`).

MCP servers are tracked separately in `claude/mcp.json` and synced via:

```
make claude-mcp
```

This compares `claude/mcp.json` against the live config in `~/.claude.json` and adds or updates servers as needed — servers already configured correctly are skipped. It will warn about any servers configured on the machine that aren't in the file, but won't remove them automatically.

To add a new MCP server, add an entry to `claude/mcp.json`:

```json
// Remote HTTP server
"my-server": { "transport": "http", "url": "https://example.com/mcp" }

// Local stdio server
"my-local": { "transport": "stdio", "command": "npx", "args": ["my-mcp-package"], "env": { "API_KEY": "xxx" } }
```

Then run `make claude-mcp`.

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


## Building tmux from source

Ubuntu's apt repos lag well behind upstream tmux releases (e.g. 22.04 "jammy" ships 3.2a, which is missing options like `allow-passthrough` needed by Claude Code). There's no trustworthy/maintained PPA for newer tmux, so build from the official release tarball instead:

```bash
sudo apt-get install -y libevent-dev ncurses-dev build-essential bison pkg-config autoconf automake

cd /tmp
curl -fsSL -o tmux.tar.gz https://github.com/tmux/tmux/releases/download/<VERSION>/tmux-<VERSION>.tar.gz
tar xzf tmux.tar.gz
cd tmux-<VERSION>
./configure --prefix="$HOME/.local"
make -j"$(nproc)"
make install
```

`~/.local/bin` is already on the fish `$PATH` ahead of `/usr/bin`, so the new binary takes over automatically — check with `which tmux` / `tmux -V`.

Note: an already-running tmux server keeps using the old binary/config until you `tmux kill-server` (this ends all panes) and start a fresh session.

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

## Installing `tree-sitter-cli`

Install instructions: https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md

When installing via `cargo install tree-sitter-cli`, the build requires `clang` to generate bindings. Without it you'll get a `fatal error: 'stdbool.h' file not found` error.

```bash
sudo apt-get update
sudo apt install clang libclang-dev
```

## Installing `fd`

Installing `fd` swaps fzf-lua to use it and it is a bit snappier than the find command.

- Ubuntu install: https://github.com/sharkdp/fd#on-ubuntu
- Mac install: https://github.com/sharkdp/fd#on-macos

## Voice Input

Software I use for voice-to-text input:

- **Linux**: [Vocalinux](https://vocalinux.com/#install)
- **Mac & Windows**: [Handy](https://handy.computer/) — also has Linux support but it didn't work for me

