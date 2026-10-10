#!/usr/bin/env bash
CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
if [ -z "$CAP" ]; then
    BAT_DEV=$(upower -e 2>/dev/null | grep BAT | head -n1)
    [ -n "$BAT_DEV" ] && CAP=$(upower -i "$BAT_DEV" 2>/dev/null | grep percentage | awk '{print $2}' | tr -d '%')
fi
[ -z "$CAP" ] && CAP=$(acpi -b 2>/dev/null | grep -oP '\d+(?=%)' | head -n1)

if [ -n "$CAP" ]; then
    echo "$CAP" | tr -d '\r\n'
else
    echo "100"
fi
