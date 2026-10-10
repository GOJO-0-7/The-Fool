#!/usr/bin/env bash

# Check global Wi-Fi status
WIFI_STATE=$(nmcli radio wifi)

if [ "$WIFI_STATE" = "disabled" ]; then
    echo '{"connected": false, "ssid": "Disabled", "icon": "󰤭"}'
    exit 0
fi

# Fetch active SSID and signal strength
CON_INFO=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes')

if [ -z "$CON_INFO" ]; then
    echo '{"connected": false, "ssid": "Disconnected", "icon": "󰤭"}'
    exit 0
fi

SSID=$(echo "$CON_INFO" | cut -d':' -f2)
SIGNAL=$(echo "$CON_INFO" | cut -d':' -f3)

# Map signal strength percentages to Nerd Font v3 Wi-Fi tiers
if [ "$SIGNAL" -ge 75 ]; then
    ICON="󰤨"
elif [ "$SIGNAL" -ge 50 ]; then
    ICON="󰤥"
elif [ "$SIGNAL" -ge 25 ]; then
    ICON="󰤢"
else
    ICON="󰤟"
fi

echo "{\"connected\": true, \"ssid\": \"$SSID\", \"icon\": \"$ICON\", \"signal\": \"$SIGNAL%\"}"
