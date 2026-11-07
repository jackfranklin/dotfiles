# Antigravity installer (Ubuntu/Debian)

Google only ships Antigravity for Linux as `.tar.gz` files (no apt repo, no
`.deb`; the old apt repo is stuck on the 1.x IDE). This script installs the
official tarball as a proper system app: `/opt/antigravity`, an app-menu entry,
an icon and an `antigravity` command.

## Usage

```bash
sudo ./install.sh          # desktop app
sudo ./install.sh --ide    # desktop app + standalone IDE
sudo ./install.sh --force  # reinstall even if already on the latest version
sudo ./install.sh --uninstall
```

**To update, just re-run it.** It skips the download if the installed version
already matches.

## How it works

It fetches https://antigravity.google/download, greps the tarball URLs out of the
HTML, downloads the one for this CPU, checks the tarball layout, and unpacks it
to `/opt`. There is no checksum verification, so it trusts Google's page.

## If it breaks

The only fragile part is `find_url`, which depends on the download page
containing plain `.../<version>/linux-x64/Antigravity.tar.gz` links. Google
rebuilt the page once already (this script replaced the community
[opensnap/antigravity](https://github.com/opensnap/antigravity) installer,
which scraped a JS bundle that no longer exists). If it says it can't find a
link, look at the page source and adjust `find_url`.
