#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃         Liquid Glass - Battery Notification Daemon            ┃
# ┃   Notifies at every 10% drop (90%, 80%, 70%... 10%)          ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

BAT_PATH="/sys/class/power_supply/BAT0"

# Exit if no battery
[ ! -d "$BAT_PATH" ] && exit 0

# Track which threshold was last notified to avoid repeats
last_notified_threshold=100

get_capacity() {
    cat "$BAT_PATH/capacity" 2>/dev/null || echo 100
}

get_status() {
    cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown"
}

# Get the current 10s-floor threshold (83% -> 80, 71% -> 70, etc.)
get_threshold() {
    echo $(( ($1 / 10) * 10 ))
}

# Initialize with current level
capacity=$(get_capacity)
last_notified_threshold=$(get_threshold "$capacity")

while true; do
    capacity=$(get_capacity)
    status=$(get_status)
    threshold=$(get_threshold "$capacity")

    # Only notify when discharging and crossing a new threshold downward
    if [ "$status" = "Discharging" ] && [ "$threshold" -lt "$last_notified_threshold" ]; then
        last_notified_threshold=$threshold

        if [ "$capacity" -le 10 ]; then
            urgency="critical"
            icon="battery-empty"
            title="Battery Critical!"
            body="Battery at ${capacity}% — plug in now"
        elif [ "$capacity" -le 20 ]; then
            urgency="critical"
            icon="battery-caution"
            title="Battery Low"
            body="Battery at ${capacity}% — consider plugging in"
        elif [ "$capacity" -le 30 ]; then
            urgency="normal"
            icon="battery-low"
            title="Battery Low"
            body="Battery at ${capacity}%"
        else
            urgency="low"
            icon="battery-good"
            title="Battery"
            body="Battery at ${capacity}%"
        fi

        notify-send -u "$urgency" -i "$icon" "$title" "$body"
    fi

    # Reset threshold tracking when charging (so it notifies again next discharge)
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        last_notified_threshold=$(get_threshold "$capacity")
    fi

    sleep 30
done
