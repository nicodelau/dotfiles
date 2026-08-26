#!/bin/bash

export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_CURRENT_DESKTOP=Hyprland

LOG="/dev/null"
MODE="$1"
DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
FILENAME="$DIR/Shot-${TIMESTAMP}.png"

mkdir -p "$DIR"

pkill -x slurp 2>/dev/null

show_notification() {
  if [ -f "$FILENAME" ]; then
    notify-send -r 699 "Screenshot" "Copied to clipboard"
  else
    notify-send -r 699 "Screenshot" "Canceled"
  fi
}

play_sound() {
  if command -v paplay &>/dev/null; then
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga >/dev/null 2>&1
  fi
}

take_screenshot() {
  sleep 0.5

  case "$1" in
  "full")
    grim "$FILENAME"
    ;;

  "area" | "select")
    TEMP_FULL="/tmp/screenshot_temp_full.png"
    grim "$TEMP_FULL"

    TIMEOUT=20
    COUNT=0
    GEOM=""

    while [ $COUNT -lt $TIMEOUT ]; do
      GEOM=$(slurp -d 2>>"$LOG")
      RET=$?

      if [ $RET -eq 0 ] && [ -n "$GEOM" ]; then
        break
      fi

      sleep 0.1
      COUNT=$((COUNT + 1))
    done

    if [ -n "$GEOM" ] && [ -f "$TEMP_FULL" ]; then
      if [[ "$GEOM" =~ ^([0-9]+),([0-9]+)\ ([0-9]+)x([0-9]+)$ ]]; then
        X="${BASH_REMATCH[1]}"
        Y="${BASH_REMATCH[2]}"
        W="${BASH_REMATCH[3]}"
        H="${BASH_REMATCH[4]}"
        CROP_GEOM="${W}x${H}+${X}+${Y}"
        convert "$TEMP_FULL" -crop "$CROP_GEOM" +repage "$FILENAME"
      else
        grim -g "$GEOM" "$FILENAME"
      fi
      rm -f "$TEMP_FULL"
    else
      echo "Slurp timed out, canceled, or temp file missing" >>"$LOG"
      rm -f "$TEMP_FULL"
      return 1
    fi
    ;;

  "window")
    sleep 0.5
    RAW_JSON=$(hyprctl activewindow -j 2>>"$LOG")
    WINDOW_GEOMETRY=$(echo "$RAW_JSON" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    WIN_W=$(echo "$RAW_JSON" | jq -r '.size[0]')
    WIN_H=$(echo "$RAW_JSON" | jq -r '.size[1]')

    if [ -n "$WINDOW_GEOMETRY" ] && [ "$WINDOW_GEOMETRY" != "null" ]; then
      grim -g "$WINDOW_GEOMETRY" "$FILENAME"

      ROUNDING=$(hyprctl getoption decoration:rounding | awk '/int:/ {print $2}')
      ROUNDING=${ROUNDING:-10}

      convert "$FILENAME" \
        \( +clone \
        -alpha extract \
        -fill black -colorize 100 \
        -fill white \
        -draw "roundrectangle 0,0 $((WIN_W - 1)),$((WIN_H - 1)) ${ROUNDING},${ROUNDING}" \
        \) \
        -alpha off \
        -compose CopyOpacity \
        -composite \
        PNG32:"$FILENAME"
    else
      return 1
    fi
    ;;
  esac
}

case "$MODE" in
"full_delay" | "area_delay")
  NOTIFY_ID=$(notify-send -p -t 5000 "Screenshot" "Taking screenshot...")
  CLOSED=false
  trap 'CLOSED=true' USR2

  gdbus monitor --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications | while read -r line; do
    if [[ "$line" == *"NotificationClosed (uint32 $NOTIFY_ID"* ]]; then
      kill -USR2 $$ 2>/dev/null
      break
    fi
  done &
  MONITOR_PID=$!

  trap 'kill $MONITOR_PID 2>/dev/null; exit 0' TERM INT EXIT

  SILENT=false
  for i in {5..1}; do
    sleep 1 &
    wait $!
  done
  if [ "$CLOSED" = true ]; then
    SILENT=true
  fi
  gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification $NOTIFY_ID >/dev/null 2>&1
  sleep 0.1
  ACTUAL_MODE=${MODE%_delay}
  take_screenshot "$ACTUAL_MODE"
  ;;
"clipboard")
  TEMP_FULL="/tmp/screenshot_temp_full.png"
  grim "$TEMP_FULL"

  GEOM=$(slurp -d 2>>"$LOG")
  if [ -n "$GEOM" ] && [ -f "$TEMP_FULL" ]; then
    if [[ "$GEOM" =~ ^([0-9]+),([0-9]+)\ ([0-9]+)x([0-9]+)$ ]]; then
      X="${BASH_REMATCH[1]}"
      Y="${BASH_REMATCH[2]}"
      W="${BASH_REMATCH[3]}"
      H="${BASH_REMATCH[4]}"
      CROP_GEOM="${W}x${H}+${X}+${Y}"
      convert "$TEMP_FULL" -crop "$CROP_GEOM" +repage png:- | wl-copy --type image/png
    else
      grim -g "$GEOM" - | wl-copy --type image/png
    fi
    play_sound
    notify-send -r 699 "Screenshot" "Area copied to clipboard"
    rm -f "$TEMP_FULL"
  else
    notify-send -r 699 "Screenshot" "Canceled"
    rm -f "$TEMP_FULL"
  fi
  exit 0
  ;;
*)
  take_screenshot "$MODE"
  ;;
esac

if [ $? -eq 0 ] && [ -f "$FILENAME" ]; then
  play_sound
  wl-copy <"$FILENAME"
  show_notification
else
  show_notification
fi
