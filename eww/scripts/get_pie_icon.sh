#!/bin/bash
# Usage: ./scripts/get_pie_icon.sh [ram|cpu|bat]

TYPE=$1

if [ "$TYPE" = "ram" ]; then
    PERC=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
elif [ "$TYPE" = "cpu" ]; then
    PERC=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')
elif [ "$TYPE" = "bat" ]; then
    PERC=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo 100)
    STATUS=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || echo "Discharging")

    # Charge hobar shomoy charging icon dekhabe
    if [ "$STATUS" = "Charging" ]; then
        echo "󰂄"
        exit 0
    fi
fi

# Percentage onujayi Round/Pie icon select kora
if [ "$PERC" -le 12 ]; then ICON="󰪞"
elif [ "$PERC" -le 25 ]; then ICON="󰪟"
elif [ "$PERC" -le 37 ]; then ICON="󰪠"
elif [ "$PERC" -le 50 ]; then ICON="󰪡"
elif [ "$PERC" -le 62 ]; then ICON="󰪢"
elif [ "$PERC" -le 75 ]; then ICON="󰪣"
elif [ "$PERC" -le 87 ]; then ICON="󰪤"
else ICON="󰪥"
fi

echo "$ICON"
