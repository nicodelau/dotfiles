#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Restore Last Wallpaper                          ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

CACHE_FILE="$HOME/.cache/current_wallpaper"
WALLPAPER_DIR="$HOME/Documents/Github/dotfiles/wallpapers"

# Wait for swww to be ready
sleep 0.3

if [ -f "$CACHE_FILE" ] && [ -f "$(cat "$CACHE_FILE")" ]; then
    # Restore last wallpaper
    swww img "$(cat "$CACHE_FILE")" --transition-type fade --transition-duration 0.5
else
    # Set first wallpaper found, or a solid color
    FIRST_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | head -1)

    if [ -n "$FIRST_WALLPAPER" ]; then
        swww img "$FIRST_WALLPAPER" --transition-type fade --transition-duration 0.5
        echo "$FIRST_WALLPAPER" > "$CACHE_FILE"
    else
        # Set solid dark color if no wallpapers found
        swww clear 14141e
    fi
fi
