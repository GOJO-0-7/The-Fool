#!/usr/bin/env bash

CACHE="$HOME/.cache/eww/music-cover.jpg"
TMP="$HOME/.cache/eww/music-cover.tmp.jpg"
META="$HOME/.cache/eww/music-cover.meta"

mkdir -p "$HOME/.cache/eww"

PLAYER="$("$HOME/.config/eww/scripts/current_player.sh")"

[ -z "$PLAYER" ] && exit 0


# ------------------------------------------------------------
# First: MPRIS artUrl
# ------------------------------------------------------------

ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

if [[ "$ART_URL" == file://* ]]; then

    FILE="${ART_URL#file://}"
    FILE="${FILE//%20/ }"

    if [ -f "$FILE" ]; then
        cp "$FILE" "$TMP" 2>/dev/null

        if [ -s "$TMP" ]; then
            mv "$TMP" "$CACHE"
            printf '%s' "$CACHE"
            exit 0
        fi
    fi

elif [[ "$ART_URL" == http://\* || "$ART_URL" == https://\* ]]; then

    curl -L \
        --fail \
        --silent \
        --show-error \
        --max-time 8 \
        "$ART_URL" \
        -o "$TMP" 2>/dev/null

    if [ -s "$TMP" ]; then
        mv "$TMP" "$CACHE"
        printf '%s' "$CACHE"
        exit 0
    fi
fi


# ------------------------------------------------------------
# VLC/local media fallback
# ------------------------------------------------------------

MEDIA_URL=$(playerctl -p "$PLAYER" metadata xesam:url 2>/dev/null)
TITLE=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)

if [[ "$MEDIA_URL" == file://* ]] && command -v ffmpeg >/dev/null 2>&1; then

    FILE="${MEDIA_URL#file://}"

    FILE="${FILE//%20/ }"
    FILE="${FILE//%5B/[}"
    FILE="${FILE//%5D/]}"
    FILE="${FILE//%28/(}"
    FILE="${FILE//%29/)}"

    if [ -f "$FILE" ]; then

        TRACK_ID="${PLAYER}|${FILE}|${TITLE}"

        if [[ ! -f "$META" || "$(cat "$META" 2>/dev/null)" != "$TRACK_ID" ]]; then

            rm -f "$TMP"

            ffmpeg \
                -hide_banner \
                -loglevel error \
                -i "$FILE" \
                -map 0:v:0 \
                -frames:v 1 \
                -q:v 2 \
                "$TMP" 2>/dev/null

            if [ -s "$TMP" ]; then
                mv "$TMP" "$CACHE"
                printf '%s' "$TRACK_ID" > "$META"
                printf '%s' "$CACHE"
                exit 0
            fi
        else
            if [ -f "$CACHE" ]; then
                printf '%s' "$CACHE"
                exit 0
            fi
        fi
    fi
fi


# Keep previous cover if current player has no artwork
if [ -f "$CACHE" ]; then
    printf '%s' "$CACHE"
fi
