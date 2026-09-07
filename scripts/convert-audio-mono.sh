#!/usr/bin/env bash
# Convert stereo audio channel of media file to mono using ffmpeg
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input-file> <output-file>"
  exit 1
fi

INPUT="$1"
OUTPUT="$2"

echo "Analyzing audio channel volumes in $INPUT..."
if ! STATS=$(ffmpeg -i "$INPUT" -filter_complex "[0:a]astats=metadata=1" -f null - 2>&1); then
  printf '%s\n' "$STATS" >&2
  exit 1
fi

# `astats` reports channel summaries followed by an overall summary. Keep the
# first RMS level for each of the two stereo channels and treat -inf as silent.
LEVELS=$(printf '%s\n' "$STATS" | awk '
  /Channel: [0-9]+/ { channel = $NF; next }
  /RMS level dB:/ && channel != "" && !(channel in level) {
    level[channel] = ($NF == "-inf" ? -1000 : $NF)
  }
  END {
    if (1 in level && 2 in level) print level[1], level[2]
  }
')

FILTER=(-ac 1)
if [[ -n "$LEVELS" ]]; then
  read -r LEFT_LEVEL RIGHT_LEVEL <<< "$LEVELS"

  if awk -v left="$LEFT_LEVEL" -v right="$RIGHT_LEVEL" \
    'BEGIN { exit !(left <= -90 && right > -90) }'; then
    echo "Left channel is silent; preserving the right channel volume."
    FILTER=(-af "pan=mono|c0=c1")
  elif awk -v left="$LEFT_LEVEL" -v right="$RIGHT_LEVEL" \
    'BEGIN { exit !(right <= -90 && left > -90) }'; then
    echo "Right channel is silent; preserving the left channel volume."
    FILTER=(-af "pan=mono|c0=c0")
  else
    echo "Both channels are active; using a standard downmix."
  fi
else
  echo "Could not read two channel levels; using a standard downmix."
fi

echo "Running ffmpeg to convert audio to mono..."
ffmpeg -i "$INPUT" -c:v copy "${FILTER[@]}" -c:a aac -b:a 256k "$OUTPUT"
echo "Done. Output saved to $OUTPUT"
