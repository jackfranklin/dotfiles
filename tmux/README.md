# Upstream Tmux Configuration

The tmux configuration is split into two files to support older tmux versions on machines where newer settings (such as `allow-passthrough`) are not supported:

- `tmux.base.conf`: Contains all cross-compatible, version-independent tmux configurations. This file is safe to source on older tmux versions (such as tmux 3.2).
- `tmux.conf`: The main entry point for upstream environments. It sources `tmux.base.conf` and adds settings that require newer tmux versions (e.g. `allow-passthrough` which was added in tmux 3.3).

If you are setting up tmux on a machine with an older tmux version, source `tmux.base.conf` instead of `tmux.conf`.
