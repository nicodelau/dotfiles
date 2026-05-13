#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃           Optimized GIF Wallpaper Setter                    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Usage: set-gif-wallpaper.sh <path_to_gif>

GIF_PATH="$1"
CACHE_FILE="$HOME/.cache/current_wallpaper"

if [ -z "$GIF_PATH" ] || [ ! -f "$GIF_PATH" ]; then
    echo "Usage: $0 <path_to_gif>"
    echo "Error: GIF file not found or not specified"
    exit 1
fi

# Check if it's actually a GIF
if ! file "$GIF_PATH" | grep -q "GIF"; then
    echo "Warning: File does not appear to be a GIF"
fi

# Set GIF wallpaper with optimized settings for performance
awww img "$GIF_PATH" \
    --transition-type simple \
    --transition-step 255 \
    --resize crop \
    --filter Nearest

# Cache the wallpaper path
echo "$GIF_PATH" > "$CACHE_FILE"

# Notify user
notify-send "Animated Wallpaper" "Set to $(basename "$GIF_PATH")" -i preferences-desktop-wallpaper

echo "GIF wallpaper set successfully: $(basename "$GIF_PATH")"