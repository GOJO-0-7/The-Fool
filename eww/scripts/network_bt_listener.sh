#!/usr/bin/env bash

last_wifi="NONE"
last_state=""

nmcli monitor | while read -r line; do
  if echo "$line" | grep -qiE "connected|disconnected"; then

    sleep 0.5

    state=$(nmcli -t -f STATE g)

    if [ "$state" = "connected" ]; then
      wifi_name=$(nmcli -t -f NAME,TYPE connection show --active | grep 802-11-wireless | cut -d: -f1 | head -n 1)
      [ -z "$wifi_name" ] && wifi_name="Wired/Unknown"

      if [ "$last_wifi" != "$wifi_name" ] || [ "$last_state" != "connected" ]; then
        last_wifi="$wifi_name"
        last_state="connected"

        eww update osd_active=true osd_icon="󰤨" osd_label="Wi-Fi Connected" osd_value="$wifi_name" osd_type="text"

        if [ -f /tmp/eww_net_timer.pid ]; then
          kill $(cat /tmp/eww_net_timer.pid) 2>/dev/null
        fi
        ( sleep 3 && eww update osd_active=false ) & echo $! > /tmp/eww_net_timer.pid
      fi

    elif [[ "$state" == "disconnected" || "$state" == "asleep" ]]; then
      if [ "$last_state" != "disconnected" ]; then
        last_wifi="NONE"
        last_state="disconnected"

        eww update osd_active=true osd_icon="󰤭" osd_label="Disconnected" osd_value="Offline" osd_type="text"

        if [ -f /tmp/eww_net_timer.pid ]; then
          kill $(cat /tmp/eww_net_timer.pid) 2>/dev/null
        fi
        ( sleep 3 && eww update osd_active=false ) & echo $! > /tmp/eww_net_timer.pid
      fi
    fi
  fi
done
