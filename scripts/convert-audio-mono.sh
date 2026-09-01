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
STATS=$(ffmpeg -i "$INPUT" -filter_complex "[0:a]astats=metadata=1" -f null - 2>&1 || true)

# Default to standard downmix
FILTER="-ac 1"

echo "Running ffmpeg to convert audio to mono..."
ffmpeg -i "$INPUT" -c:v copy $FILTER -c:a aac -b:a 256k "$OUTPUT"
echo "Done. Output saved to $OUTPUT"
