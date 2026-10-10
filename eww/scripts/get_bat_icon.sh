#!/usr/bin/env bash
CAP=$(bash ~/.config/eww/scripts/get_bat_val.sh 2>/dev/null)
STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)

if [ "$STAT" = "Charging" ]; then
    echo "󰂄"
elif [ "$CAP" -gt 80 ]; then
    echo "󰁹"
elif [ "$CAP" -gt 50 ]; then
    echo "󰂀"
elif [ "$CAP" -gt 20 ]; then
    echo "󰁞"
else
    echo "󰂎"
fi
