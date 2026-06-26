#!/bin/bash
url=$(playerctl metadata mpris:artUrl 2>/dev/null)
[ -z "$url" ] && echo "" && exit 0

if [[ "$url" == file://* ]]; then
    echo "${url#file://}"
elif [[ "$url" == http* ]]; then
    f="/tmp/eww-art.jpg"
    curl -sf "$url" -o "$f" --max-time 3 2>/dev/null && echo "$f" || echo ""
else
    echo ""
fi
