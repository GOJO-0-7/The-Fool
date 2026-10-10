#!/usr/bin/env bash

# NetworkManager Active Connection (Instant, no scanning delay)
if command -v nmcli &>/dev/null; then
    SSID=$(timeout 0.2s nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2)
fi

# Fallback using Kernel iwgetid (Instant)
if [ -z "$SSID" ] && command -v iwgetid &>/dev/null; then
    SSID=$(timeout 0.2s iwgetid -r 2>/dev/null)
fi

# Output
if [ -n "$SSID" ]; then
    echo "<span color='#00ffcc'>󰤨 $SSID</span>"
else
    echo "<span color='#ff5555'>󰤭 OFFLINE</span>"
fi
