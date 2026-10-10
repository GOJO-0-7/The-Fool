#!/usr/bin/env bash

TARGET="$1"
POS=$(echo "$TARGET" | cut -d'.' -f1 | cut -d',' -f1 | tr -cd '0-9')

[ -z "$POS" ] && exit 0

PLAYER="$(scripts/get_player.sh)"

mkdir -p /tmp/eww_music
echo "$POS" > /tmp/eww_music/seek_pos
touch /tmp/eww_music/seeking

eww update music_position="$POS" 2>/dev/null

if [ -n "$PLAYER" ]; then
    playerctl -p "$PLAYER" position "$POS" 2>/dev/null
else
    playerctl position "$POS" 2>/dev/null
fi

(sleep 2 && rm -f /tmp/eww_music/seeking) &
