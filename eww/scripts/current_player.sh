#!/usr/bin/env bash

# ------------------------------------------------------------
# Choose the player we actually want to control.
#
# Priority:
#   1. VLC
#   2. Spotify
#   3. Firefox
#   4. Any other Playing player
#   5. Any Paused player
# ------------------------------------------------------------

# VLC first
for p in $(playerctl -l 2>/dev/null); do
    if [[ "$p" == vlc* ]] && [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
        echo "$p"
        exit 0
    fi
done

# Spotify
for p in $(playerctl -l 2>/dev/null); do
    if [[ "$p" == spotify* ]] && [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
        echo "$p"
        exit 0
    fi
done

# Firefox
for p in $(playerctl -l 2>/dev/null); do
    if [[ "$p" == firefox* ]] && [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
        echo "$p"
        exit 0
    fi
done

# Any other Playing player
while read -r p; do
    [[ -z "$p" ]] && continue

    if [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
        echo "$p"
        exit 0
    fi
done < <(playerctl -l 2>/dev/null)

# If nothing is Playing, use VLC if available
for p in $(playerctl -l 2>/dev/null); do
    if [[ "$p" == vlc* ]]; then
        echo "$p"
        exit 0
    fi
done

# Otherwise any available player
playerctl -l 2>/dev/null | head -n1
