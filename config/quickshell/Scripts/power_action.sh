#!/bin/bash

export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_CURRENT_DESKTOP=Hyprland
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}

LABEL="$1"
shift
CMD=("$@")

case "$LABEL" in
"shutdown") ;;
"reboot") ;;
"suspend") ;;
"logout") ;;
esac

PID_FILE="/tmp/quickshell_power_action.pid"
echo $$ >"$PID_FILE"

ACCEPT=false
trap 'ACCEPT=true' USR1

trap 'rm -f "$PID_FILE"; exit 0' TERM INT

LOG="/tmp/quickshell_power.log"
echo "$(date): Action triggered: ${LABEL}" >"$LOG"

NOTIFY_ID=$(notify-send -p -t 11000 "Power Menu" "Confirming ${LABEL}...")

if [ -z "$NOTIFY_ID" ]; then

  echo "$(date): Fallback triggered (no ID)" >>"$LOG"
  notify-send "Confirming ${LABEL}..."
  sleep 10
  "${CMD[@]}"
  exit 0
fi

CLOSED=false
trap 'CLOSED=true' USR2

gdbus monitor --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications | while read -r line; do
  if [[ "$line" == *"NotificationClosed (uint32 $NOTIFY_ID"* ]]; then
    kill -USR2 $$ 2>/dev/null
    break
  fi
done &
MONITOR_PID=$!

trap 'kill $MONITOR_PID 2>/dev/null; rm -f "$PID_FILE"; exit 0' TERM INT EXIT

for i in {10..1}; do
  if [ "$ACCEPT" = true ]; then
    echo "$(date): Accepted via signal" >>"$LOG"
    break
  fi
  if [ "$CLOSED" = true ]; then
    echo "$(date): Closed by user, canceling action" >>"$LOG"
    exit 0
  fi

  sleep 1 &
  wait $!
done

if [ "$CLOSED" = true ]; then
  echo "$(date): Closed by user after loop, canceling action" >>"$LOG"
  exit 0
fi

echo "$(date): Executing: ${CMD[*]}" >>"$LOG"

gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.CloseNotification \
  $NOTIFY_ID >/dev/null 2>&1 &

"${CMD[@]}"
