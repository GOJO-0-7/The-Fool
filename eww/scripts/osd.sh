#!/usr/bin/env bash

TIMER_FILE="/tmp/eww_osd_timer"
TYPE="$1"   # volume | brightness | caps | num
ACTION="$2" # up | down | toggle / mute

case "$TYPE" in
volume)
  if [ "$ACTION" = "up" ]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ 2>/dev/null || pamixer -i 5
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null
  elif [ "$ACTION" = "down" ]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- 2>/dev/null || pamixer -d 5
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null
  elif [ "$ACTION" = "mute" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pamixer -t
  fi

  # Audio status check (wpctl focus, fallback pamixer)
  AUDIO_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  if [ -n "$AUDIO_INFO" ]; then
    VOL=$(echo "$AUDIO_INFO" | awk '{print int($2*100)}')
    if echo "$AUDIO_INFO" | grep -q "MUTED"; then
      IS_MUTED="true"
    else
      IS_MUTED="false"
    fi
  else
    VOL=$(pamixer --get-volume 2>/dev/null || echo "0")
    if [ "$(pamixer --get-mute 2>/dev/null)" = "true" ]; then
      IS_MUTED="true"
    else
      IS_MUTED="false"
    fi
  fi

  # Dynamic Island Update for Mute vs Active Volume
  if [ "$IS_MUTED" = "true" ]; then
    eww update osd_icon="󰝟" osd_label="Muted" osd_value=0 osd_type="bar" osd_active=true
  else
    if [ "$VOL" -gt 60 ]; then
      ICON="󰕾"
    elif [ "$VOL" -gt 20 ]; then
      ICON="󰖀"
    else
      ICON="󰕿"
    fi
    eww update osd_icon="$ICON" osd_label="Volume" osd_value="$VOL" osd_type="bar" osd_active=true
  fi
  ;;

brightness)
  if [ "$ACTION" = "up" ]; then
    brightnessctl set +5%
  elif [ "$ACTION" = "down" ]; then
    brightnessctl set 5%-
  fi

  BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
  eww update osd_icon="󰃠" osd_label="Brightness" osd_value="$BRIGHT" osd_type="bar" osd_active=true
  ;;

caps)
  sleep 0.08
  STATE=$(cat /sys/class/leds/*::capslock/brightness 2>/dev/null | grep -m1 "1" || echo "0")

  if [ "$STATE" = "1" ]; then
    VAL="ON"
  else
    VAL="OFF"
  fi
  eww update osd_icon="󰬈" osd_label="Caps Lock" osd_value="$VAL" osd_type="badge" osd_active=true
  ;;

num)
  sleep 0.08
  STATE=$(cat /sys/class/leds/*::numlock/brightness 2>/dev/null | grep -m1 "1" || echo "0")

  if [ "$STATE" = "1" ]; then
    VAL="ON"
  else
    VAL="OFF"
  fi
  eww update osd_icon="󰎤" osd_label="Num Lock" osd_value="$VAL" osd_type="badge" osd_active=true
  ;;

esac
# Auto close timer reset (1.8s)
if [ -f "$TIMER_FILE" ]; then
  kill "$(cat "$TIMER_FILE")" 2>/dev/null
fi

(
  sleep 1.4
  eww update osd_active=false
  rm -f "$TIMER_FILE"
) &

echo $! >"$TIMER_FILE"
