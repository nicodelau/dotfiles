#!/bin/bash

# App Icon Resolver - Maps application classes to icon paths

get_app_icon() {
    local app_class="$1"
    local icon_theme="${2:-Papirus}"
    local icon_size="${3:-48x48}"
    local icon_base="/usr/share/icons/$icon_theme/$icon_size/apps"
    local fallback_icon="$icon_base/application-x-executable.svg"
    
    # Normalize app class to lowercase for matching
    app_class_lower=$(echo "$app_class" | tr '[:upper:]' '[:lower:]')
    
    # Direct mappings for common applications
    case "$app_class_lower" in
        # Web browsers
        "firefox"|"navigator"|"firefox-bin")
            echo "$icon_base/firefox.svg"
            return 0
            ;;
        "chrome"|"google-chrome"|"chromium"|"chromium-browser")
            echo "$icon_base/google-chrome.svg"
            return 0
            ;;
        "brave"|"brave-browser")
            echo "$icon_base/brave.svg"
            return 0
            ;;
        
        # Communication
        "discord")
            echo "$icon_base/discord.svg"
            return 0
            ;;
        "telegram"|"telegram-desktop")
            echo "$icon_base/telegram.svg"
            return 0
            ;;
        "slack")
            echo "$icon_base/slack.svg"
            return 0
            ;;
        "whatsapp"|"whatsapp-desktop")
            echo "$icon_base/whatsapp.svg"
            return 0
            ;;
        
        # Gaming
        "steam")
            echo "$icon_base/steam.svg"
            return 0
            ;;
        
        # Development
        "code"|"visual-studio-code"|"vscode")
            echo "$icon_base/code.svg"
            return 0
            ;;
        "atom")
            echo "$icon_base/atom.svg"
            return 0
            ;;
        "sublime_text"|"sublime-text")
            echo "$icon_base/sublime-text.svg"
            return 0
            ;;
        
        # Terminals
        "wezterm"|"org.wezfurlong.wezterm"|"wezterm-gui")
            echo "$icon_base/terminal.svg"
            return 0
            ;;
        "alacritty")
            echo "$icon_base/alacritty.svg"
            return 0
            ;;
        "kitty")
            echo "$icon_base/kitty.svg"
            return 0
            ;;
        "gnome-terminal"|"terminal")
            echo "$icon_base/gnome-terminal.svg"
            return 0
            ;;
        
        # Media
        "spotify")
            echo "$icon_base/spotify.svg"
            return 0
            ;;
        "vlc")
            echo "$icon_base/vlc.svg"
            return 0
            ;;
        "mpv")
            echo "$icon_base/mpv.svg"
            return 0
            ;;
        
        # File managers
        "nautilus"|"files")
            echo "$icon_base/nautilus.svg"
            return 0
            ;;
        "thunar")
            echo "$icon_base/thunar.svg"
            return 0
            ;;
        "dolphin")
            echo "$icon_base/dolphin.svg"
            return 0
            ;;
        
        # Other applications
        "helium")
            echo "$icon_base/internet-web-browser.svg"
            return 0
            ;;
        "obsidian")
            echo "$icon_base/obsidian.svg"
            return 0
            ;;
        
        *)
            # Try to find icon by exact name match
            if [[ -f "$icon_base/$app_class_lower.svg" ]]; then
                echo "$icon_base/$app_class_lower.svg"
                return 0
            fi
            
            # Try partial matches
            local possible_icon=$(find "$icon_base" -name "*$app_class_lower*" -type f | head -1)
            if [[ -n "$possible_icon" ]]; then
                echo "$possible_icon"
                return 0
            fi
            
            # Return fallback icon
            echo "$fallback_icon"
            return 1
            ;;
    esac
}

# If called directly, get icon for the provided app class
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <app_class> [icon_theme] [icon_size]"
        echo "Example: $0 firefox Papirus 48x48"
        exit 1
    fi
    
    get_app_icon "$@"
fi