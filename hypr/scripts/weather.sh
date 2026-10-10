#!/usr/bin/env bash

LOCATION="RAJSHAHI"

DATA=$(curl -s --max-time 3 "wttr.in/${LOCATION}?format=%c~%t~%f~%h~%w~%C~%l" 2>/dev/null)

if [[ -n "$DATA" && "$DATA" == *"~"* ]]; then
    IFS='~' read -r ICON TEMP FEELS HUM WIND COND CITY <<< "$DATA"

    CITY_NAME=$(echo "$CITY" | cut -d',' -f1 | tr '[:lower:]' '[:upper:]' | xargs)
    [ -z "$CITY_NAME" ] && CITY_NAME="LOCAL"

    ICON=$(echo "$ICON" | xargs)
    TEMP=$(echo "$TEMP" | xargs)
    FEELS=$(echo "$FEELS" | xargs)
    HUM=$(echo "$HUM" | xargs)
    WIND=$(echo "$WIND" | xargs)
    COND=$(echo "$COND" | xargs)

    echo "<b><span color='#00ffcc'>󰖐 SYS_WX // ${CITY_NAME}</span></b>"
    echo "<span color='#ffffff'>${ICON} ${COND} ${TEMP}</span> <span color='#555555'>|</span> <span color='#8c96a0'>Feels: ${FEELS}</span>"
    echo "<span color='#8c96a0'>󰍎 Hum: ${HUM}</span> <span color='#555555'>|</span> <span color='#8c96a0'>󰈐 Wind: ${WIND}</span>"
else
    echo "<span color='#ff5555'>󰖐 WX_SERVICE // OFFLINE</span>"
fi
