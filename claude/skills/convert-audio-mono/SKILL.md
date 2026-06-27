---
disable-model-invocation: true
name: convert-audio-mono
description: Use when the user wants to convert a video or audio file's stereo audio to mono, or fix audio that only plays in one ear.
---

# Convert Audio to Mono

## Overview
This skill converts the stereo audio channel of a media file (typically video or audio) to mono. It optimizes the process by copying the video stream without re-encoding to preserve video quality, and handles silent channels by extracting the active channel rather than a simple downmix.

## When to Use
Use when a video or audio file's sound plays in only one ear/channel, or when a mono mix is requested.

## Core Pattern
1. **Analyze Channel Volumes**:
   Run `ffmpeg -i <input> -filter_complex "[0:a]astats=metadata=1" -f null -` to identify the peak and RMS volume of each channel.
   *Note: Do not use `reset=1` in the filter, as it resets stats per frame.*
2. **Determine Extraction Strategy**:
   - If one channel is silent (volume ~ -90 dB or less) and the other has sound, isolate the active channel to avoid a 6 dB volume drop from normal averaging:
     - Left channel only: `-af "pan=mono|c0=c0"` (or `FL`)
     - Right channel only: `-af "pan=mono|c0=c1"` (or `FR`)
   - If both channels have active sound, use standard downmixing:
     - `-ac 1`
3. **Execute Conversion**:
   Run ffmpeg, copying the video stream to save time and preserve quality:
   `ffmpeg -i <input> -c:v copy -af "<filter>" -c:a aac -b:a 256k <output>`

## Common Mistakes
- **Re-encoding video**: Re-encoding the video stream degrades quality and takes significant time. Always use `-c:v copy`.
- **Averaging silent channels**: A simple `-ac 1` downmix of a one-eared track averages it with silence, dropping the overall volume by 6 dB. Always analyze first and use the `pan` filter for single-channel isolation.
