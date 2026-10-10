#!/usr/bin/env bash

# Power Profile check
if command -v powerprofilesctl &> /dev/null; then
    PROFILE=$(powerprofilesctl get 2>/dev/null | tr '[:lower:]' '[:upper:]')
else
    PROFILE="BALANCED"
fi
[ -z "$PROFILE" ] && PROFILE="BALANCED"

# Battery Path check
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)

if [ -n "$BAT_PATH" ] && [ -f "$BAT_PATH/capacity" ]; then
    CAPACITY=$(cat "$BAT_PATH/capacity")"%"
    STATUS=$(cat "$BAT_PATH/status")
    if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
        PWR_STATE="AC"
    else
        PWR_STATE="BAT"
    fi
else
    CAPACITY="100%"
    PWR_STATE="AC"
fi

echo "PWR <span color='#00ffcc'>$PROFILE</span> <span color='#ffffff'>$CAPACITY</span> <span color='#888888'>$PWR_STATE</span>"
