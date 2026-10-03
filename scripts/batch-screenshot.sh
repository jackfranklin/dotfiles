#!/usr/bin/env bash
# Bind a temporary GNOME hotkey that saves a screenshot each time you press it.
# Installs gnome-screenshot if needed, and on exit removes the hotkey and
# uninstalls gnome-screenshot again (only if this script installed it).
#
# Usage: batch-screenshot.sh [output_dir] [hotkey]
#   hotkey uses GNOME accelerator syntax, default <Ctrl><Alt>p
set -euo pipefail

schema=org.gnome.settings-daemon.plugins.media-keys
key_path=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/batch-screenshot/

# Invoked by the hotkey itself: batch-screenshot.sh --snap <output_dir>
if [[ "${1:-}" == "--snap" ]]; then
  shopt -s nullglob
  existing=("$2"/*.png)
  gnome-screenshot -f "$2/$(printf '%04d' $((${#existing[@]} + 1))).png"
  exit 0
fi

out_dir="$(realpath -m "${1:-$HOME/Pictures/batch-screenshots/$(date +%Y%m%d-%H%M%S)}")"
hotkey="${2:-<Ctrl><Alt>p}"
self="$(realpath "$0")"
installed_by_us=false

# Prints the custom keybinding list with $key_path added or removed.
edit_binding_list() {
  python3 - "$1" "$key_path" "$(gsettings get $schema custom-keybindings)" <<'EOF'
import ast, sys
action, path, current = sys.argv[1], sys.argv[2], sys.argv[3]
paths = [] if current.startswith("@as") else ast.literal_eval(current)
paths = [p for p in paths if p != path]
if action == "add":
    paths.append(path)
print(repr(paths))
EOF
}

cleanup() {
  echo
  gsettings set $schema custom-keybindings "$(edit_binding_list remove)"
  dconf reset -f "$key_path"
  echo "Removed hotkey $hotkey."

  if $installed_by_us; then
    echo "Uninstalling gnome-screenshot..."
    sudo apt-get remove -y gnome-screenshot >/dev/null
  fi

  shopt -s nullglob
  local files=("$out_dir"/*.png)
  echo "Saved ${#files[@]} screenshots to $out_dir"
}

if ! command -v gnome-screenshot >/dev/null; then
  echo "Installing gnome-screenshot..."
  sudo apt-get install -y gnome-screenshot >/dev/null
  installed_by_us=true
fi

mkdir -p "$out_dir"
trap cleanup EXIT
trap 'exit 0' INT TERM

# Values are wrapped in double quotes so gsettings parses each one as a single
# GVariant string, even when it contains single quotes.
gsettings set "$schema.custom-keybinding:$key_path" name '"Batch screenshot"'
gsettings set "$schema.custom-keybinding:$key_path" command "\"'$self' --snap '$out_dir'\""
gsettings set "$schema.custom-keybinding:$key_path" binding "\"$hotkey\""
gsettings set $schema custom-keybindings "$(edit_binding_list add)"

echo "Press $hotkey to take a screenshot (gnome-screenshot plays a shutter sound)."
echo "Saving to $out_dir"
read -rp "Press Enter here when you're done. "
