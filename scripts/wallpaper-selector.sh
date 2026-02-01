#!/bin/bash
# Wallpaper Selector with rofi

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"

mkdir -p "$CACHE_DIR"

# Check if wallpaper directory exists and has files
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    notify-send "Wallpaper Selector" "No wallpapers in $WALLPAPER_DIR" -i dialog-warning
    exit 1
fi

# Get wallpapers (follow symlinks)
mapfile -t wallpapers < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Wallpaper Selector" "No image files found" -i dialog-warning
    exit 1
fi

# Build rofi menu
menu=""
for wp in "${wallpapers[@]}"; do
    name=$(basename "$wp" | sed 's/\.[^.]*$//')
    # Create thumbnail if imagemagick is available
    thumb="$CACHE_DIR/$(basename "$wp" | sed 's/\./_thumb./')"
    if [ ! -f "$thumb" ] && command -v convert &>/dev/null; then
        convert "$wp" -resize 200x120^ -gravity center -extent 200x120 "$thumb" 2>/dev/null &
    fi
    if [ -f "$thumb" ]; then
        menu+="$name\x00icon\x1f$thumb\n"
    else
        menu+="$name\n"
    fi
done

# Get active monitor for rofi
active_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)

# Show rofi on active monitor and get selection
selected=$(echo -e "$menu" | rofi -dmenu -i -p "Wallpaper" -theme ~/.config/rofi/wallpaper.rasi -format "i" -m "$active_monitor")

if [ -n "$selected" ] && [ "$selected" -ge 0 ] 2>/dev/null; then
    chosen="${wallpapers[$selected]}"
    if [ -f "$chosen" ]; then
        # Set wallpaper with swww
        swww img "$chosen" --transition-type grow --transition-pos center --transition-duration 1 --transition-fps 60
        # Save for persistence
        echo "$chosen" > "$HOME/.cache/current_wallpaper"
        notify-send "Wallpaper" "Changed to $(basename "$chosen")" -i preferences-desktop-wallpaper
    fi
fi
