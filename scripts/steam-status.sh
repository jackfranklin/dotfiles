#!/usr/bin/env bash
# Report whether Steam is running and, when available, its client-update progress.
set -euo pipefail

steam_dir=""
for candidate in \
  "${STEAM_DIR:-}" \
  "$HOME/.local/share/Steam" \
  "$HOME/snap/steam/common/.local/share/Steam"; do
  if [[ -n "$candidate" && -d "$candidate" ]]; then
    steam_dir="$candidate"
    break
  fi
done

mapfile -t steam_pids < <(pgrep -x steam || true)

if ((${#steam_pids[@]} == 0)); then
  echo "Steam is not running."
else
  echo "Steam is running:"
  ps -p "$(IFS=,; echo "${steam_pids[*]}")" -o pid=,etimes=,pcpu=,pmem=,args=

  connections=0
  for pid in "${steam_pids[@]}"; do
    count=$(ss -tnpH 2>/dev/null | grep -Fc "pid=${pid}," || true)
    connections=$((connections + count))
  done
  if ((connections > 0)); then
    echo "Active TCP connections: $connections"
  fi

  if pgrep -x steamwebhelper >/dev/null; then
    echo "Steam UI: running"
  else
    echo "Steam UI: not started yet (normal while a client update is installing)"
  fi
fi

if [[ -z "$steam_dir" ]]; then
  echo "Steam data directory was not found. Set STEAM_DIR to inspect a custom installation."
  exit 0
fi

bootstrap_log="$steam_dir/logs/bootstrap_log.txt"
if [[ ! -f "$bootstrap_log" ]]; then
  echo "No bootstrap log found at $bootstrap_log"
  exit 0
fi

last_download=$(grep -aE 'Downloading update \([0-9]+ of [0-9]+ KB\)' "$bootstrap_log" | tail -n 1 || true)
if [[ -n "$last_download" && "$last_download" =~ \(([0-9]+)\ of\ ([0-9]+)\ KB\) ]]; then
  downloaded=${BASH_REMATCH[1]}
  total=${BASH_REMATCH[2]}
  percent=$((downloaded * 100 / total))
  remaining_mib=$(awk -v downloaded="$downloaded" -v total="$total" 'BEGIN { printf "%.1f", (total - downloaded) / 1024 }')
  echo "Client update download: ${downloaded}/${total} KB (${percent}%; ${remaining_mib} MiB remaining)"
fi

last_state=$(grep -aE 'Downloading update|Found pending update|Installing update|Extracting package|Verifying installation|Update complete' "$bootstrap_log" | tail -n 1 || true)
if [[ -n "$last_state" ]]; then
  echo "Latest update activity: ${last_state#*] }"
fi
