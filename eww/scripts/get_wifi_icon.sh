#!/usr/bin/env bash
SSID=$(bash ~/.config/eww/scripts/get_wifi_ssid.sh 2>/dev/null)
if [ "$SSID" != "Disconnected" ] && [ -n "$SSID" ]; then
    echo "󰤨"
else
    echo "󰤭"
fi
