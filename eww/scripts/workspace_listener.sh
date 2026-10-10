#!/usr/bin/env bash

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Hyprland is not running or HYPRLAND_INSTANCE_SIGNATURE is not set."
    exit 1
fi

handle() {
  case $1 in
    "workspace>>"*)
      ws_id=$(hyprctl activeworkspace -j | jq -r '.id')
      win_title=$(hyprctl activewindow -j | jq -r '.class')
      
      if [ "$win_title" = "null" ] || [ -z "$win_title" ]; then
          win_title="Desktop"
      fi
      
      eww update ws_id="$ws_id" ws_title="${win_title^}" ws_active=true
      
      if [ -f /tmp/eww_ws_timer.pid ]; then
          kill $(cat /tmp/eww_ws_timer.pid) 2>/dev/null
      fi

      ( sleep 2 && eww update ws_active=false ) & echo $! > /tmp/eww_ws_timer.pid
      ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
