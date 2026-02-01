#!/bin/bash
# Workspace indicator - shows on the monitor where workspace changed

HIDE_DELAY=1.5

# Get monitor ID from workspace event
get_workspace_monitor() {
    local ws="$1"
    # Get the monitor ID where this workspace is
    hyprctl monitors -j | jq -r ".[] | select(.activeWorkspace.id == $ws) | .id" 2>/dev/null || echo "0"
}

# Get focused monitor
get_focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .id' 2>/dev/null || echo "0"
}

# Show workspace indicator temporarily
show_workspace() {
    local monitor="$1"

    # Kill any pending hide
    pkill -f "sleep.*eww close workspace" 2>/dev/null

    eww close workspace 2>/dev/null
    eww open workspace --screen "$monitor"

    # Auto-hide after delay
    (sleep "$HIDE_DELAY" && eww close workspace) &
}

# Listen for workspace changes
socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - 2>/dev/null | while read -r line; do
    case "$line" in
        workspace\>\>*)
            # Extract workspace number
            ws="${line#workspace>>}"
            monitor=$(get_workspace_monitor "$ws")
            [ -z "$monitor" ] && monitor=$(get_focused_monitor)
            show_workspace "$monitor"
            ;;
        focusedmon\>\>*)
            # Monitor changed, show on new focused monitor
            monitor=$(get_focused_monitor)
            show_workspace "$monitor"
            ;;
    esac
done
