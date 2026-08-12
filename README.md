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

## Wi-Fi power saving

On Ubuntu systems managed by NetworkManager, Wi-Fi power saving can reduce throughput or cause intermittent slow connections. `iw` controls it for the current session; NetworkManager can disable it persistently.

### Find the Wi-Fi interface

Install `iw` if it is not already present:

```bash
sudo apt update
sudo apt install iw
```

List wireless interfaces:

```bash
iw dev
```

Use the value after `Interface` as the interface name below—for example, `wlp0s20f3`. To confirm it is the active Wi-Fi connection and see its NetworkManager profile:

```bash
WIFI_IFACE=wlp0s20f3 # replace with the Interface value from `iw dev`
nmcli device status
nmcli -g GENERAL.CONNECTION device show "$WIFI_IFACE"
```

### Check and temporarily disable power saving

Check the current setting:

```bash
iw dev "$WIFI_IFACE" get power_save
```

If it reports `Power save: on`, disable it until the next reboot or NetworkManager reconnect:

```bash
sudo iw dev "$WIFI_IFACE" set power_save off
```

Run the `get power_save` command again to confirm it reports `Power save: off`.

### Disable power saving permanently

Set NetworkManager's global default to disable Wi-Fi power saving for all connections:

```bash
sudo install -d /etc/NetworkManager/conf.d
printf '[connection]\nwifi.powersave = 2\n' \
  | sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null
```

Here, `2` means disabled. Restart NetworkManager to test the setting immediately; this briefly disconnects Wi-Fi:

```bash
sudo systemctl restart NetworkManager
iw dev "$WIFI_IFACE" get power_save
```

The final command should report `Power save: off`. The setting survives reboots and future NetworkManager reconnects.

## Building nvim

1. Clone nvim to `~/git/neovim`.
1. `git pull` if required on `master.`
1. `git checkout <tag>` if you want a stable version.
1. Build with the right flags:
    ```
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim
    ```
1. `make install`


## Updating tmux

Ubuntu's apt repos lag behind upstream tmux releases. Install the current tmux release locally with:

```bash
make tmux_latest
```

This installs the required build dependencies, downloads tmux `3.7b` from its official GitHub release, and installs it under `~/.local`. To install a different release, pass its version explicitly:

```bash
make tmux_latest TMUX_VERSION=3.7a
```

`~/.local/bin` is ahead of `/usr/bin` on the Fish `$PATH`, so the new binary takes over automatically. Verify it with `which tmux` and `tmux -V`.

An already-running tmux server keeps using the old binary and configuration. After the install, end all tmux panes and start a new server:

```bash
tmux kill-server
tmux
```

The tmux configuration enables CSI-u extended keys automatically on tmux 3.5 and newer, so Pi can distinguish `Shift+Enter` from `Enter`.

## WezTerm on Windows

The Windows WezTerm → WSL setup needs a machine-local `Shift+Enter` mapping for Pi. In `wezterm/per_machine.lua` (which is ignored by Git), add:

```lua
M.keys = {
  {
    key = "Enter",
    mods = "SHIFT",
    action = require("wezterm").action.SendString("\n"),
  },
}
```

Then run `make sync_wezterm_windows` and fully restart Windows WezTerm. The shared config appends `M.keys` to its standard keybindings.

This is deliberately Windows-only. On the Linux machines, WezTerm's normal extended-key reporting distinguishes `Shift+Enter`; this Windows-to-WSL path instead delivers it as an ordinary Enter. The mapping sends line feed—the same input as Pi's default `Ctrl+J` newline binding—rather than a literal backslash or a normal carriage-return Enter. The underlying reason is not yet established, but is likely specific to keyboard-protocol negotiation through the Windows/WSL terminal path.

## WezTerm on Ubuntu

Use WezTerm's nightly APT package on Ubuntu. It includes Wayland fixes that are not present in Ubuntu's older stable package. Configure WezTerm's official APT repository and install the nightly package:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://apt.fury.io/wez/gpg.key \
  | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
  | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /etc/apt/keyrings/wezterm-fury.gpg
sudo apt update
sudo apt install wezterm-nightly
```

`wezterm-nightly` replaces the stable `wezterm` package; APT cannot install both. Verify the installed build with:

```bash
wezterm --version
```

If a distribution upgrade renamed the repository file to `wezterm.list.distUpgrade`, re-enable it before updating:

```bash
sudo mv /etc/apt/sources.list.d/wezterm.list.distUpgrade \
  /etc/apt/sources.list.d/wezterm.list
```

A running WezTerm instance continues using its old executable. Quit every WezTerm window and start it again after the install. Future nightly updates arrive through normal `sudo apt upgrade`.

### Ubuntu Wayland troubleshooting

On the Framework's Ubuntu GNOME Wayland session, a 2026 nightly exhibited an oversized client-side decoration frame and a slightly fuzzy mouse pointer. Native Wayland still produced crisp terminal text, so the current machine-local preference is a borderless native-Wayland window:

```lua
-- wezterm/per_machine.lua (ignored by Git)
M.use_xwayland = false
M.window_decorations = "NONE"
M.font_size = 12
```

`wezterm/wezterm.lua` reads these optional per-machine settings. `NONE` removes the titlebar, resize border, and window buttons. Move the borderless window with **Super + left-mouse drag** (or **Ctrl+Shift + left-mouse drag**); ordinary dragging selects terminal text.

If a future nightly regresses native Wayland text, cursor, or window handling, first try the XWayland fallback in `wezterm/per_machine.lua`:

```lua
M.use_xwayland = true
M.window_decorations = "NONE"
```

XWayland gave crisp terminal text and a correctly rendered system cursor, but GNOME may impose a large titlebar unless decorations are set to `NONE`. Do not add a `dpi` override merely for the mouse cursor: it only affects terminal text. This display uses GNOME's integer 2x scale, so native Wayland should already select HiDPI rendering. Explicit `xcursor_theme = "Yaru"` and cursor-size overrides of 24 and 48 were tested without improving the native Wayland cursor.

Useful references: [WezTerm window decorations](https://wezterm.org/config/lua/config/window_decorations.html), [Wayland toggle](https://wezterm.org/config/lua/config/enable_wayland.html), [DPI](https://wezterm.org/config/lua/config/dpi.html), and [a related GNOME Wayland cursor issue](https://github.com/wez/wezterm/issues/3751).

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

