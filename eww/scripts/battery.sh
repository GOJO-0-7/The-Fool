#!/usr/bin/env bash

BAT_PATH=$(sysfs_path=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1); echo "$sysfs_path")

if [ -z "$BAT_PATH" ]; then
    case "$1" in
        "icon") echo "󰂄" ;;
        "val") echo "100" ;;
        "tooltip") echo "No Battery Found" ;;
        *) echo "100%" ;;
    esac
    exit 0
fi

CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "100")
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Discharging")

case "$1" in
    "val")
        echo "$CAPACITY"
        ;;
    "icon")
        if [ "$STATUS" = "Charging" ]; then
            echo "󰂄"
        elif [ "$CAPACITY" -gt 80 ]; then
            echo "󰁹"
        elif [ "$CAPACITY" -gt 50 ]; then
            echo "󰂀"
        elif [ "$CAPACITY" -gt 20 ]; then
            echo "󰁞"
        else
            echo "󰂎"
        fi
        ;;
    "tooltip")
        echo "Battery: $CAPACITY% ($STATUS)"
        ;;
    *)
        echo "$CAPACITY%"
        ;;
esac
