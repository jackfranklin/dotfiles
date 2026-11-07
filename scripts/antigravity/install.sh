#!/usr/bin/env bash
# Install / update Google Antigravity on Debian/Ubuntu as a proper system app
# (/opt, menu entry, icon, `antigravity` command). Google only ships tarballs.
#
#   sudo ./install.sh          # Antigravity desktop app (default)
#   sudo ./install.sh --ide    # also the standalone Antigravity IDE
#   sudo ./install.sh --force  # reinstall even if version matches
#   sudo ./install.sh --uninstall
set -euo pipefail

DOWNLOAD_PAGE="https://antigravity.google/download"
WANT_IDE=0
FORCE=0
UNINSTALL=0
TMPDIR_=""

for arg in "$@"; do
  case "$arg" in
    --ide) WANT_IDE=1 ;;
    --force) FORCE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

if [ "$UNINSTALL" -eq 1 ]; then
  rm -rf /opt/antigravity /opt/antigravity-ide
  rm -f /usr/local/bin/antigravity /usr/local/bin/antigravity-ide
  rm -f /usr/share/applications/antigravity.desktop /usr/share/applications/antigravity-ide.desktop
  rm -f /usr/share/icons/hicolor/512x512/apps/antigravity.png /usr/share/icons/hicolor/512x512/apps/antigravity-ide.png
  update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
  echo "Removed. User settings in your home directory were left alone."
  exit 0
fi

case "$(uname -m)" in
  x86_64) PLATFORM="linux-x64";  APP_TOP="Antigravity-x64" ;;
  aarch64) PLATFORM="linux-arm"; APP_TOP="Antigravity-arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

apt-get install -y ca-certificates curl tar python3 desktop-file-utils >/dev/null

TMPDIR_=$(mktemp -d /var/tmp/antigravity-install.XXXXXX)
trap 'rm -rf "$TMPDIR_"' EXIT

curl -fsSL --compressed --retry 3 -o "$TMPDIR_/page.html" "$DOWNLOAD_PAGE"

# Tarball links are plain URLs in the page HTML:
#   .../<version>/<platform>/Antigravity.tar.gz  and  .../Antigravity%20IDE.tar.gz
find_url() {
  grep -oE "https://[^\"' <>)]*/$PLATFORM/$1" "$TMPDIR_/page.html" | head -n1
}

version_of() { sed -E 's#.*/([0-9]+\.[0-9]+\.[0-9]+)-[0-9]+/.*#\1#' <<<"$1"; }

# install_tarball <name> <url-file-pattern> <top-dir-in-tarball> <launcher> <opt-dir> <bin-name>
install_tarball() {
  local name="$1" pattern="$2" top="$3" launcher="$4" root="$5" bin="$6"
  local url version
  url=$(find_url "$pattern")
  [ -n "$url" ] || { echo "Could not find $name download link on $DOWNLOAD_PAGE (page layout changed?)" >&2; exit 1; }
  version=$(version_of "$url")

  if [ "$FORCE" -eq 0 ] && [ "$(cat "$root/.version" 2>/dev/null || true)" = "$version" ]; then
    echo "$name $version already installed."
    return
  fi

  echo "Downloading $name $version ..."
  local archive="$TMPDIR_/$bin.tar.gz" stage="$TMPDIR_/$bin"
  mkdir -p "$stage"
  curl -fL --retry 3 -o "$archive" "$url"
  [ "$(tar -tzf "$archive" | sed -n '1{s#/.*##;p;q}')" = "$top" ] || { echo "Unexpected tarball layout for $name" >&2; exit 1; }
  tar -xzf "$archive" -C "$stage"
  [ -x "$stage/$top/$launcher" ] || { echo "$launcher missing from tarball" >&2; exit 1; }

  rm -rf "$root.new" "$root.previous"
  mkdir -p "$root.new"
  cp -a "$stage/$top" "$root.new/app"
  echo "$version" > "$root.new/.version"
  chown root:root "$root.new/app/chrome-sandbox"
  chmod 4755 "$root.new/app/chrome-sandbox"
  [ -d "$root" ] && mv "$root" "$root.previous"
  mv "$root.new" "$root"
  rm -rf "$root.previous"
  ln -sfn "$root/app/$launcher" "/usr/local/bin/$bin"
  echo "Installed $name $version in $root"
}

# The desktop app keeps its icon inside app.asar; pull icon.png out of it.
extract_asar_icon() {
  python3 - "$1" "$2" <<'PY'
import json, struct, sys
with open(sys.argv[1], 'rb') as f:
    f.read(4)
    header_size = struct.unpack('<I', f.read(4))[0]
    f.read(4)
    json_size = struct.unpack('<I', f.read(4))[0]
    header = json.loads(f.read(json_size).decode())
    icon = header['files']['icon.png']
    f.seek(8 + header_size + int(icon['offset']))
    open(sys.argv[2], 'wb').write(f.read(int(icon['size'])))
PY
}

ICONS=/usr/share/icons/hicolor/512x512/apps
mkdir -p "$ICONS" /usr/share/applications

install_tarball "Antigravity" "Antigravity\.tar\.gz" "$APP_TOP" antigravity /opt/antigravity antigravity
extract_asar_icon /opt/antigravity/app/resources/app.asar "$ICONS/antigravity.png" \
  || echo "Warning: could not extract icon" >&2
cat > /usr/share/applications/antigravity.desktop <<DESKTOP
[Desktop Entry]
Name=Antigravity
Comment=Google Antigravity
Exec=/usr/local/bin/antigravity %U
Icon=antigravity
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=Antigravity
DESKTOP

if [ "$WANT_IDE" -eq 1 ]; then
  install_tarball "Antigravity IDE" "Antigravity%20IDE\.tar\.gz" "Antigravity IDE" antigravity-ide /opt/antigravity-ide antigravity-ide
  install -m 0644 /opt/antigravity-ide/app/resources/app/resources/linux/code.png "$ICONS/antigravity-ide.png" || true
  cat > /usr/share/applications/antigravity-ide.desktop <<DESKTOP
[Desktop Entry]
Name=Antigravity IDE
Comment=Google Antigravity IDE
Exec=/usr/local/bin/antigravity-ide %F
Icon=antigravity-ide
Terminal=false
Type=Application
Categories=Development;IDE;
MimeType=inode/directory;text/plain;
StartupNotify=true
StartupWMClass=antigravity-ide
DESKTOP
fi

update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
gtk-update-icon-cache -q /usr/share/icons/hicolor >/dev/null 2>&1 || true
echo "Done. Launch Antigravity from the app menu (you may need to log out/in for the icon)."
