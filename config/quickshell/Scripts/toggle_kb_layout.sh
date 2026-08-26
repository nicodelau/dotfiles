#!/bin/bash

CURRENT_LAYOUT=$(hyprctl getoption input:kb_layout -j | jq -r '.str')
CURRENT_LAYOUT=$(echo "$CURRENT_LAYOUT" | xargs)

if [[ "$CURRENT_LAYOUT" == us* ]]; then
  NEW_LAYOUT="latam"
else
  NEW_LAYOUT="us"
fi

hyprctl eval "hl.config({input = {kb_layout = '$NEW_LAYOUT'}})"

notify-send "Keyboard Layout" "Switched to $NEW_LAYOUT"
