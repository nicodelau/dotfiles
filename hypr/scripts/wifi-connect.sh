#!/bin/bash
# Connect to a WiFi network (called from eww inline panel)
SSID="$1"
INTERFACE="wlan0"
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

current=$(iwctl station "$INTERFACE" show 2>/dev/null | strip_ansi | grep "Connected network" | sed 's/.*Connected network\s*//' | xargs)

[ "$SSID" = "$current" ] && exit 0

known=$(iwctl known-networks list 2>/dev/null | strip_ansi | grep -F "$SSID")
if [ -n "$known" ]; then
    notify-send "WiFi" "Connecting to $SSID..." -t 3000
    iwctl station "$INTERFACE" connect "$SSID" 2>/dev/null
else
    active_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)
    password=$(rofi -dmenu -p "Password for $SSID" -password -theme ~/.config/rofi/glass.rasi -m "$active_monitor" 2>/dev/null)
    [ -z "$password" ] && exit 0
    notify-send "WiFi" "Connecting to $SSID..." -t 3000
    iwctl station "$INTERFACE" connect "$SSID" --passphrase "$password" 2>/dev/null
fi
