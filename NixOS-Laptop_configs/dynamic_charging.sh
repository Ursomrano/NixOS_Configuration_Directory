#!/bin/sh

BAT="/sys/class/power_supply/BAT0"

# Ensure battery exists
[ -d "$BAT" ] || exit 0

TEMP_FILE="$BAT/temp"
END="$BAT/charge_control_end_threshold"
START="$BAT/charge_control_start_threshold"

# Read temp safely
TEMP=$(cat "$TEMP_FILE" 2>/dev/null || echo 0)
TEMP_C=$((TEMP / 10))

# Add hysteresis buffer
STATE_FILE="/run/battery_charge_state"

if [ ! -f "$STATE_FILE" ]; then
  echo "cool" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$TEMP_C" -lt 33 ]; then
    NEW_STATE="cool"
elif [ "$TEMP_C" -gt 37 ]; then
    NEW_STATE="hot"
else
    NEW_STATE="$STATE"
fi

# Only act if state changed
if [ "$NEW_STATE" != "$STATE" ]; then

    if [ "$NEW_STATE" = "cool" ]; then
        echo 100 > "$END"
        echo 95  > "$START"
    else
        echo 85 > "$END"
        echo 84 > "$START"
    fi

    echo "$NEW_STATE" > "$STATE_FILE"
fi
