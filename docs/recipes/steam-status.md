# Check Steam Startup and Update Progress

When Steam appears not to open, it may still be downloading or installing a client update before starting its UI.

## Script

```bash
bash ~/dotfiles/scripts/steam-status.sh
```

The script reports Steam processes, active TCP connections, whether the UI has started, and the latest client-update progress from Steam's bootstrap log. It supports both regular Linux and Snap Steam data directories.

For a custom installation directory, pass it through `STEAM_DIR`:

```bash
STEAM_DIR=/path/to/Steam bash ~/dotfiles/scripts/steam-status.sh
```
