#!/usr/bin/env bash
SSID=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d':' -f2 | head -n1)
[ -z "$SSID" ] && SSID=$(iwgetid -r 2>/dev/null)
[ -z "$SSID" ] && SSID=$(iwctl station wlan0 show 2>/dev/null | grep "Connected network" | awk '{print $3}')

if [ -n "$SSID" ]; then
    echo "$SSID" | tr -d '\r\n'
else
    echo "Disconnected"
fi
