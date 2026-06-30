#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Restore & Update Random Wallpaper              ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

CACHE_FILE="$HOME/.cache/current_wallpaper"
LOCK_FILE="$HOME/.cache/wallpaper_locked"
DEFAULT_WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Wait for awww daemon to be fully ready
sleep 0.3

# 1. Restore the last wallpaper immediately for a fast startup
if [ -f "$CACHE_FILE" ] && [ -f "$(cat "$CACHE_FILE")" ]; then
    awww img "$(cat "$CACHE_FILE")" --transition-type fade --transition-duration 0.5
else
    # Fallback to any local wallpaper or solid color if cache doesn't exist
    FIRST_WALLPAPER=$(find -L "$DEFAULT_WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | head -1)
    if [ -n "$FIRST_WALLPAPER" ]; then
        awww img "$FIRST_WALLPAPER" --transition-type fade --transition-duration 0.5
        echo "$FIRST_WALLPAPER" > "$CACHE_FILE"
    else
        awww clear 14141e
    fi
fi

# 2. In the background, download a new random wallpaper and transition to it
# Only if the wallpaper is not locked (permanent)
if [ ! -f "$LOCK_FILE" ]; then
    ~/.config/hypr/scripts/set-random-wallpaper.sh &
else
    echo "Wallpaper is pinned (permanent). Skipping automatic update."
fi
