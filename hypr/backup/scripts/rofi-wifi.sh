#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃         Liquid Glass - WiFi Selector (rofi + iwd)            ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

INTERFACE="wlan0"

# Strip ANSI escape codes
strip_ansi() {
    sed 's/\x1b\[[0-9;]*m//g'
}

# Get current connection info
current_ssid=$(iwctl station "$INTERFACE" show 2>/dev/null | strip_ansi | grep "Connected network" | sed 's/.*Connected network\s*//' | xargs)

# Scan for networks
iwctl station "$INTERFACE" scan 2>/dev/null
sleep 1.5

# Get known networks list
known_networks=$(iwctl known-networks list 2>/dev/null | strip_ansi | tail -n +5 | sed 's/^\s*//' | awk '{print $1}')

# Parse available networks from iwctl output
# Format after stripping ANSI: "  >   SSID                psk    ****"
networks=$(iwctl station "$INTERFACE" get-networks 2>/dev/null | strip_ansi | tail -n +5 | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$(echo "$line" | xargs)" ] && continue

    # Check if this is the connected network (starts with >)
    is_connected=$(echo "$line" | grep -c "^[[:space:]]*>")

    # Extract signal strength (count asterisks at end of line)
    signal_count=$(echo "$line" | grep -oP '\*+' | tail -1 | wc -c)
    signal_count=$((signal_count - 1))

    # Extract SSID: remove leading markers and trailing security/signal info
    # Remove leading whitespace and optional "> "
    ssid=$(echo "$line" | sed 's/^\s*>\?\s*//' | sed 's/\s*\(psk\|open\|8021x\)\s*\**\s*$//' | xargs)

    [ -z "$ssid" ] && continue

    # Build signal bar
    case $signal_count in
        4) sig="████" ;;
        3) sig="███░" ;;
        2) sig="██░░" ;;
        1) sig="█░░░" ;;
        *) sig="░░░░" ;;
    esac

    # Check if known network
    is_known=""
    echo "$known_networks" | grep -qxF "$ssid" && is_known="★ "

    if [ "$is_connected" -eq 1 ]; then
        echo "✓ ${ssid}  ${sig}  ${is_known}connected"
    else
        echo "  ${ssid}  ${sig}  ${is_known}"
    fi
done)

# Add actions at the top
menu=""
if [ -n "$current_ssid" ]; then
    menu="󰤭  Disconnect ($current_ssid)
"
fi
menu+="󰑐  Rescan Networks
─────────────────────────
$networks"

# Get active monitor for rofi
active_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null)

# Show in rofi
selected=$(echo "$menu" | rofi -dmenu -i -p "  WiFi" -theme ~/.config/rofi/glass.rasi -m "$active_monitor" 2>/dev/null)

[ -z "$selected" ] && exit 0

# Handle separator line
echo "$selected" | grep -q "^─" && exit 0

# Handle rescan
if echo "$selected" | grep -q "Rescan"; then
    notify-send "WiFi" "Scanning for networks..." -i network-wireless -t 2000
    iwctl station "$INTERFACE" scan 2>/dev/null
    sleep 2
    exec "$0"
fi

# Handle disconnect
if echo "$selected" | grep -q "Disconnect"; then
    iwctl station "$INTERFACE" disconnect 2>/dev/null
    notify-send "WiFi" "Disconnected from $current_ssid" -i network-wireless-disconnected
    exit 0
fi

# Extract SSID from selection
ssid=$(echo "$selected" | sed 's/^[✓ ]*//' | sed 's/\s*[█░]*\s*[★ ]*\(connected\)\?\s*$//' | xargs)

[ -z "$ssid" ] && exit 0

# Skip if already connected to this network
if [ "$ssid" = "$current_ssid" ]; then
    notify-send "WiFi" "Already connected to $ssid" -i network-wireless -t 2000
    exit 0
fi

# Check if this is a known network
is_known=$(iwctl known-networks list 2>/dev/null | strip_ansi | grep -F "$ssid")

if [ -n "$is_known" ]; then
    notify-send "WiFi" "Connecting to $ssid..." -i network-wireless -t 3000
    iwctl station "$INTERFACE" connect "$ssid" 2>/dev/null
    sleep 3
    new_ssid=$(iwctl station "$INTERFACE" show 2>/dev/null | strip_ansi | grep "Connected network" | sed 's/.*Connected network\s*//' | xargs)
    if [ "$new_ssid" = "$ssid" ]; then
        notify-send "WiFi" "Connected to $ssid" -i network-wireless
    else
        notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-disconnected
    fi
else
    # Unknown network - prompt for password
    password=$(rofi -dmenu -p "  Password for $ssid" -password -theme ~/.config/rofi/glass.rasi -m "$active_monitor" 2>/dev/null)
    if [ -n "$password" ]; then
        notify-send "WiFi" "Connecting to $ssid..." -i network-wireless -t 3000
        iwctl station "$INTERFACE" connect "$ssid" --passphrase "$password" 2>/dev/null
        sleep 3
        new_ssid=$(iwctl station "$INTERFACE" show 2>/dev/null | strip_ansi | grep "Connected network" | sed 's/.*Connected network\s*//' | xargs)
        if [ "$new_ssid" = "$ssid" ]; then
            notify-send "WiFi" "Connected to $ssid" -i network-wireless
        else
            notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-disconnected
        fi
    fi
fi
