#!/bin/bash
# Audio Output Selector (rofi + pactl)

active_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)
default_sink=$(pactl get-default-sink 2>/dev/null)

menu=$(pactl list sinks 2>/dev/null | grep -E "^\s+Name:|^\s+Description:" | paste - - | \
    sed 's/\s*Name: //; s/\s*Description: /|/' | \
    while IFS='|' read -r name desc; do
        if [ "$name" = "$default_sink" ]; then
            echo "✓  $desc|$name"
        else
            echo "   $desc|$name"
        fi
    done)

[ -z "$menu" ] && notify-send "Audio" "No output devices found" -t 2000 && exit 0

selected=$(echo "$menu" | cut -d'|' -f1 | \
    rofi -dmenu -i -p "󰕾  Audio Output" -theme ~/.config/rofi/glass.rasi -m "$active_monitor" 2>/dev/null)

[ -z "$selected" ] && exit 0

tech_name=$(echo "$menu" | grep "^${selected}|" | cut -d'|' -f2)
[ -z "$tech_name" ] && exit 0

pactl set-default-sink "$tech_name"
friendly=$(echo "$selected" | sed 's/^[✓ ]*//' | xargs)
notify-send "Audio Output" "$friendly" -t 2000
