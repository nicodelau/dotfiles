#!/bin/bash

# Task Manager script for Hyprland - Lists running applications and system processes

ICON_SCRIPT="$HOME/.config/hypr/scripts/app-icons.sh"

get_applications() {
    # Get all Hyprland windows with class and title, then add icons
    local apps_json=$(hyprctl clients -j | jq -s '
        .[] |
        map(select(.workspace.id > 0)) |
        group_by(.class) |
        map({
            class: .[0].class,
            count: length,
            windows: .
        })
    ')
    
    # Add icon information to each app
    echo "$apps_json" | jq -c '.[]' | while read -r app; do
        app_class=$(echo "$app" | jq -r '.class')
        icon_path=$(~/.config/hypr/scripts/app-icons.sh "$app_class")
        echo "$app" | jq ". + {icon: \"$icon_path\"}"
    done | jq -s '.'
}

get_system_processes() {
    # Get top CPU consuming processes (excluding kernel threads)
    ps -eo pid,ppid,comm,pcpu,pmem --sort=-pcpu --no-headers | \
    head -20 | \
    while IFS=' ' read -r pid ppid comm cpu mem; do
        # Skip kernel threads (commands in brackets)
        if [[ ! $comm =~ ^\[.*\]$ ]] && [[ -n "$pid" ]] && [[ -n "$comm" ]]; then
            # Get icon for the process
            icon_path=$($ICON_SCRIPT "$comm")
            
            echo "{\"pid\":$pid,\"name\":\"$comm\",\"cpu\":\"$cpu\",\"mem\":\"$mem\",\"icon\":\"$icon_path\"}"
        fi
    done | jq -s '.'
}

get_background_services() {
    # Get systemd user services that are running
    systemctl --user list-units --state=running --no-pager --no-legend | \
    awk '{print $1}' | \
    while read -r service; do
        if [[ $service == *.service ]]; then
            name=$(echo "$service" | sed 's/.service$//' | sed 's/\\x2d/-/g')
            status=$(systemctl --user is-active "$service" 2>/dev/null)
            
            # Get icon for the service (clean name for icon lookup)
            clean_name=$(echo "$name" | sed 's/^app-//' | sed 's/@.*$//')
            icon_path=$($ICON_SCRIPT "$clean_name")
            
            # Escape name for JSON
            name_escaped=$(echo "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
            service_escaped=$(echo "$service" | sed 's/\\/\\\\/g; s/"/\\"/g')
            
            echo "{\"name\":\"$name_escaped\",\"service\":\"$service_escaped\",\"status\":\"$status\",\"icon\":\"$icon_path\"}"
        fi
    done | jq -s '.'
}

get_background_apps() {
    # Common background applications that users might want to manage
    local bg_apps=("steam" "discord" "spotify" "slack" "telegram" "whatsapp" "code" "chrome" "firefox" "thunderbird" "obs" "gimp" "blender" "wine")
    
    # Get all running processes and check for background apps
    local bg_json=$(ps -eo pid,comm --no-headers | while read -r pid comm; do
        # Check if this process matches any of our background apps
        for app in "${bg_apps[@]}"; do
            if [[ "$comm" =~ $app ]]; then
                # Check if this app has any visible windows in Hyprland
                has_window=$(hyprctl clients -j | jq -r ".[] | select(.pid == $pid) | .class" 2>/dev/null)
                
                # If no window found, it's a background app
                if [[ -z "$has_window" ]]; then
                    # Get more details about the process
                    process_info=$(ps -p "$pid" -o pid,comm,cmd --no-headers 2>/dev/null)
                    if [[ -n "$process_info" ]]; then
                        echo "{\"pid\":$pid,\"name\":\"$comm\",\"app\":\"$app\",\"hasWindow\":false}"
                    fi
                fi
                break
            fi
        done
    done | jq -s '
        # Group by app name and remove duplicates
        group_by(.app) |
        map({
            app: .[0].app,
            name: .[0].name,
            pid: .[0].pid,
            count: length,
            hasWindow: false
        })
    ')
    
    # Add icon information to each background app
    echo "$bg_json" | jq -c '.[]' | while read -r app; do
        if [[ -n "$app" ]]; then
            app_name=$(echo "$app" | jq -r '.app')
            icon_path=$(~/.config/hypr/scripts/app-icons.sh "$app_name")
            echo "$app" | jq ". + {icon: \"$icon_path\"}"
        fi
    done | jq -s '.'
}

case "$1" in
    "apps")
        get_applications
        ;;
    "background")
        get_background_apps
        ;;
    "processes")
        get_system_processes
        ;;
    "services")
        get_background_services
        ;;
    "kill")
        if [[ -n "$2" ]]; then
            kill -TERM "$2" 2>/dev/null
            echo "Sent TERM signal to process $2"
        fi
        ;;
    "force-kill")
        if [[ -n "$2" ]]; then
            kill -KILL "$2" 2>/dev/null
            echo "Sent KILL signal to process $2"
        fi
        ;;
    "close-window")
        if [[ -n "$2" ]]; then
            hyprctl dispatch closewindow "pid:$2"
            echo "Closed window for PID $2"
        fi
        ;;
    "focus-window")
        if [[ -n "$2" ]]; then
            hyprctl dispatch focuswindow "pid:$2"
            echo "Focused window for PID $2"
        fi
        ;;
    "restore-app")
        if [[ -n "$2" ]] && [[ -n "$3" ]]; then
            # $2 is app name, $3 is PID
            app_name="$2"
            pid="$3"
            
            # Try to restore/show the application
            # First try to find if it has any hidden windows
            window_info=$(hyprctl clients -j | jq -r ".[] | select(.pid == $pid)")
            if [[ -n "$window_info" ]]; then
                hyprctl dispatch focuswindow "pid:$pid"
                echo "Focused existing window for PID $pid"
            else
                case "$app_name" in
                    "steam")
                        # For Steam, try opening the Steam URI or use steam command
                        steam steam://open/main 2>/dev/null &
                        echo "Opened Steam main window"
                        ;;
                    "discord")
                        # For Discord, try to show the window
                        kill -USR1 "$pid" 2>/dev/null
                        echo "Sent show signal to Discord"
                        ;;
                    *)
                        # Generic approach for other apps
                        kill -USR1 "$pid" 2>/dev/null || kill -USR2 "$pid" 2>/dev/null
                        echo "Sent restore signal to $app_name (PID $pid)"
                        ;;
                esac
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {apps|background|processes|services|kill|force-kill|close-window|focus-window|restore-app} [pid]"
        echo ""
        echo "Commands:"
        echo "  apps         - List Hyprland windows/applications"
        echo "  background   - List background apps without windows (Steam, Discord, etc.)"
        echo "  processes    - List top CPU consuming processes"
        echo "  services     - List running systemd user services"
        echo "  kill PID     - Terminate process gracefully"
        echo "  force-kill PID - Force kill process"
        echo "  close-window PID - Close Hyprland window by PID"
        echo "  focus-window PID - Focus Hyprland window by PID"
        echo "  restore-app PID  - Try to restore/show background application"
        exit 1
        ;;
esac