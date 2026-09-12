# Convert Audio to Mono

## Overview
Converts the stereo audio channel of a media file (video or audio) to mono without re-encoding the video stream.

## Script
Run the helper script. It analyzes both channels and preserves the active channel's volume when the other is silent:
```bash
~/dotfiles/scripts/convert-audio-mono.sh <input-file> <output-file>
```

## Manual FFMPEG Commands

### 1. Analyze Channel Volumes
```bash
ffmpeg -i <input> -filter_complex "[0:a]astats=metadata=1" -f null -
```

### 2. Determine Strategy
- **One silent channel (<= -90 dB)**: isolate active channel to prevent 6 dB volume drop:
  - Left only: `-af "pan=mono|c0=c0"`
  - Right only: `-af "pan=mono|c0=c1"`
- **Both channels active**:
  - `-ac 1`

### 3. Run Conversion
```bash
ffmpeg -i <input> -c:v copy -af "<filter>" -c:a aac -b:a 256k <output>
```
