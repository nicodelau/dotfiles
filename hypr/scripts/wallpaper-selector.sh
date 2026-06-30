#!/bin/bash
# Wallpaper Selector with rofi

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
LOCK_FILE="$HOME/.cache/wallpaper_locked"

mkdir -p "$CACHE_DIR"

# Check if wallpaper directory exists and has files
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    notify-send "Wallpaper Selector" "No wallpapers in $WALLPAPER_DIR" -i dialog-warning
    exit 1
fi

# Get wallpapers (follow symlinks)
mapfile -t wallpapers < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Wallpaper Selector" "No image files found" -i dialog-warning
    exit 1
fi

# Build rofi menu
menu="🎲 Obtener wallpaper aleatorio\x00icon\x1fmedia-playlist-shuffle\n"
if [ -f "$LOCK_FILE" ]; then
    menu+="🔓 Liberar fondo actual (Permanente)\x00icon\x1fchanges-allow\n"
else
    menu+="📌 Fijar fondo actual (Temporal)\x00icon\x1fchanges-prevent\n"
fi

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
    if [ "$selected" -eq 0 ]; then
        # Run the random wallpaper script (which also unlocks it)
        ~/.config/hypr/scripts/set-random-wallpaper.sh
        notify-send "Wallpaper" "Descargando nuevo fondo aleatorio..." -i preferences-desktop-wallpaper
    elif [ "$selected" -eq 1 ]; then
        # Toggle lock state for current wallpaper
        if [ -f "$LOCK_FILE" ]; then
            rm -f "$LOCK_FILE"
            notify-send "Wallpaper" "Fondo liberado. Cambiará en el próximo inicio de sesión." -i changes-allow
        else
            touch "$LOCK_FILE"
            notify-send "Wallpaper" "Fondo fijado. Quedará de forma permanente." -i changes-prevent
        fi
    else
        # Select manual wallpaper (shifted by 2 because of the two custom options)
        chosen="${wallpapers[$((selected - 2))]}"
        if [ -f "$chosen" ]; then
            # Check if it's a GIF for optimized handling
            if [[ "${chosen,,}" == *.gif ]]; then
                # GIF: Use simpler transition for better performance
                awww img "$chosen" --transition-type simple --transition-step 255 --filter Nearest
                notify-send "Animated Wallpaper" "Fijado permanentemente: $(basename "$chosen")" -i preferences-desktop-wallpaper
            else
                # Static image: Use fancy transition
                awww img "$chosen" --transition-type grow --transition-pos center --transition-duration 1 --transition-fps 60
                notify-send "Wallpaper" "Fijado permanentemente: $(basename "$chosen")" -i preferences-desktop-wallpaper
            fi
            # Save for persistence
            echo "$chosen" > "$HOME/.cache/current_wallpaper"
            
            # Automatically lock/pin the manually selected wallpaper
            touch "$LOCK_FILE"
        fi
    fi
fi
