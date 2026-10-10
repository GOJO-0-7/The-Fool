#!/usr/bin/env bash

PLAYER="$("$HOME/.config/eww/scripts/current_player.sh")"

[ -z "$PLAYER" ] && exit 0

case "$1" in
    previous)
        playerctl -p "$PLAYER" previous
        ;;
    play-pause)
        playerctl -p "$PLAYER" play-pause
        ;;
    next)
        playerctl -p "$PLAYER" next
        ;;
esac
