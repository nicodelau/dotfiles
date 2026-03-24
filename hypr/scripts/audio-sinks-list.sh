#!/bin/bash
# Outputs audio sinks as JSON array for eww's (for) loop
default=$(pactl get-default-sink 2>/dev/null)

result=$(pactl list sinks 2>/dev/null | grep -E "^\s+Name:|^\s+Description:" | paste - - | \
    sed 's/\s*Name: //; s/\s*Description: /|/' | \
    while IFS='|' read -r name desc; do
        active="false"
        [ "$name" = "$default" ] && active="true"
        n=$(echo "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
        d=$(echo "$desc" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "{\"name\":\"$n\",\"desc\":\"$d\",\"active\":$active}"
    done)

[ -z "$result" ] && echo "[]" && exit 0
echo "$result" | jq -s '.' 2>/dev/null || echo "[]"
