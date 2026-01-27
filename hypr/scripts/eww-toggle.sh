#!/bin/bash
# EWW Widget Toggle - Opens on active monitor

widget="$1"

if [ -z "$widget" ]; then
    echo "Usage: eww-toggle.sh <widget-name>"
    exit 1
fi

# Get active monitor ID
get_active_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .id' 2>/dev/null || echo "0"
}

# Check if widget is open
is_open() {
    eww active-windows 2>/dev/null | grep -q "$1"
}

# Toggle widget on active monitor
toggle() {
    local monitor=$(get_active_monitor)

    if is_open "$1"; then
        eww close "$1"
    else
        # Close other popups first
        for popup in clock powermenu media; do
            if [ "$popup" != "$1" ] && is_open "$popup"; then
                eww close "$popup"
            fi
        done
        eww open "$1" --screen "$monitor"
    fi
}

# Show temporarily and auto-close
show_temp() {
    local monitor=$(get_active_monitor)
    local duration="${2:-2}"

    # Kill any existing auto-close for this widget
    pkill -f "sleep.*eww close $1" 2>/dev/null

    eww close "$1" 2>/dev/null
    eww open "$1" --screen "$monitor"
    (sleep "$duration" && eww close "$1") &
}

case "$widget" in
    clock)
        # Clock shows for 1 second
        show_temp "$widget" 1
        ;;
    osd-volume|osd-brightness|workspace)
        # OSD shows for 2 seconds
        show_temp "$widget" 2
        ;;
    *)
        toggle "$widget"
        ;;
esac
