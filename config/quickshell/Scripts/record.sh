#!/bin/bash

# Export essential environment variables for Wayland/Hyprland
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_CURRENT_DESKTOP=Hyprland

echo "--- Record started at $(date) ---" >>"$LOG"

# Output directory
DIR="$HOME/Videos/Recordings"
mkdir -p "$DIR"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
FILENAME="$DIR/Recording-${TIMESTAMP}.mkv"

# If already running, stop it cleanly
if pidof wf-recorder >/dev/null; then
  echo "wf-recorder is running, stopping it..." >>"$LOG"
  killall -SIGINT wf-recorder
  notify-send "Screen Recorder" "Recording finished and saved to Videos/Recordings"
  exit 0
fi

AUDIO="none"
REGION=""

while getopts "sr" opt; do
  case $opt in
  s)
    AUDIO="$(pactl get-default-sink).monitor"
    ;;
  r)
    # Select region
    GEOM=$(slurp)
    if [ -z "$GEOM" ]; then
      notify-send "Screen Recorder" "Recording canceled"
      echo "Region selection canceled" >>"$LOG"
      exit 0
    fi
    REGION="-g $GEOM"
    ;;
  esac
done

# Get active monitor for Wayland
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
if [ -z "$MONITOR" ] || [ "$MONITOR" = "null" ]; then
  MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')
fi

echo "Recording monitor: $MONITOR" >>"$LOG"
echo "Region: $REGION" >>"$LOG"
echo "Audio: $AUDIO" >>"$LOG"
echo "Output: $FILENAME" >>"$LOG"

notify-send "Screen Recorder" "Starting recording..."

if [ -z "$REGION" ]; then
  TARGET="-o $MONITOR"
else
  TARGET="$REGION"
fi

# Run wf-recorder
if [ "$AUDIO" != "none" ]; then
  pactl set-source-mute "$AUDIO" false
  wf-recorder $TARGET --audio="$AUDIO" -x yuv420p -p color_range=tv -p color_primaries=bt709 -p color_trc=bt709 -p colorspace=bt709 -c libx264 -f "$FILENAME"
else
  wf-recorder $TARGET -x yuv420p -p color_range=tv -p color_primaries=bt709 -p color_trc=bt709 -p colorspace=bt709 -c libx264 -f "$FILENAME"
fi

echo "wf-recorder exited with code $?" >>"$LOG"
