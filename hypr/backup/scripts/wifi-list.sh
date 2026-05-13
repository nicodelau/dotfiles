#!/bin/bash
# Outputs WiFi networks as JSON array for eww's (for) loop
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

current=$(iwctl station wlan0 show 2>/dev/null | strip_ansi | grep "Connected network" | sed 's/.*Connected network\s*//' | xargs)

result=$(iwctl station wlan0 get-networks 2>/dev/null | strip_ansi | tail -n +5 | while IFS= read -r line; do
    [ -z "$(echo "$line" | xargs)" ] && continue
    ssid=$(echo "$line" | sed 's/^\s*>\?\s*//' | sed 's/\s*\(psk\|open\|8021x\)\s*\**\s*$//' | xargs)
    [ -z "$ssid" ] && continue
    connected="false"
    [ "$ssid" = "$current" ] && connected="true"
    ssid_j=$(echo "$ssid" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"ssid\":\"$ssid_j\",\"connected\":$connected}"
done)

[ -z "$result" ] && echo "[]" && exit 0
echo "$result" | jq -s '.' 2>/dev/null || echo "[]"
