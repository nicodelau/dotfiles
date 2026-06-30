#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Set Random Wallpaper from URL                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

CACHE_FILE="$HOME/.cache/current_wallpaper"
LOCK_FILE="$HOME/.cache/wallpaper_locked"
DOWNLOAD_DIR="$HOME/Pictures/wallpapers"
URL="https://minimalistic-wallpaper.demolab.com/?random"

mkdir -p "$DOWNLOAD_DIR"

# Wait up to 20 seconds for internet connection (useful on boot/login)
connected=0
for i in {1..20}; do
    if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        connected=1
        break
    fi
    sleep 1
done

if [ $connected -ne 1 ]; then
    echo "No internet connection. Keeping current wallpaper."
    exit 0
fi

# 1. Fetch the redirected URL to get the filename (without downloading the image body)
FINAL_URL=$(curl -s -I -L -w "%{url_effective}" -o /dev/null "$URL")

if [ -n "$FINAL_URL" ]; then
    FILENAME=$(basename "$FINAL_URL")
    # If no file extension in filename, default to jpeg
    if [[ ! "$FILENAME" =~ \. ]]; then
        FILENAME="wallpaper.jpg"
    fi
    
    TARGET_PATH="$DOWNLOAD_DIR/$FILENAME"
    
    # 2. Check if the wallpaper already exists locally
    if [ -f "$TARGET_PATH" ]; then
        echo "Wallpaper $FILENAME already exists locally. Using local copy."
    else
        # Download the image since it's new
        echo "Downloading new wallpaper: $FILENAME"
        curl -s -L -o "$TARGET_PATH" "$FINAL_URL"
        if [ $? -ne 0 ] || [ ! -s "$TARGET_PATH" ]; then
            echo "Error downloading wallpaper from $FINAL_URL"
            rm -f "$TARGET_PATH"
            exit 1
        fi
    fi
    
    # Apply the wallpaper with a nice transition
    if command -v awww &>/dev/null; then
        awww img "$TARGET_PATH" --transition-type fade --transition-duration 1.5
    fi
    
    # Save to cache for persistence
    echo "$TARGET_PATH" > "$CACHE_FILE"
    
    # When triggering a new random wallpaper, we unlock it so it changes next login
    rm -f "$LOCK_FILE"
    
    echo "Successfully updated wallpaper to $FILENAME"
else
    echo "Error fetching redirect URL from $URL"
    exit 1
fi
