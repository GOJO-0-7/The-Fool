#!/bin/bash

status=$(playerctl status 2>/dev/null)

case "$status" in
    "Playing")
        title=$(playerctl metadata title 2>/dev/null)
        artist=$(playerctl metadata artist 2>/dev/null)
        text="/ ${title}"
        tooltip="${artist} — ${title}"
        ;;
    "Paused")
        title=$(playerctl metadata title 2>/dev/null)
        artist=$(playerctl metadata artist 2>/dev/null)
        text="\ ${title}"
        tooltip="${artist} — ${title} (Paused)"
        ;;
    *)
        text="/ NONE"
        tooltip="No media playing"
        ;;
esac

jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
