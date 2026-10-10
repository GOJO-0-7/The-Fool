#!/usr/bin/env bash

PLAYER="$("$HOME/.config/eww/scripts/current_player.sh")"

[ -z "$PLAYER" ] && exit 0

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

[ "$STATUS" = "No player could handle this command" ] && exit 0


# ============================================================
# VLC
# ============================================================

if [[ "$PLAYER" == vlc* ]]; then

    URL=$(playerctl -p "$PLAYER" metadata xesam:url 2>/dev/null)

    if [[ "$URL" == file://* ]]; then

        FILE="${URL#file://}"

        # URL decode using python
        FILE=$(python3 - "$FILE" <<'PY'
import sys
from urllib.parse import unquote

print(unquote(sys.argv[1]))
PY
)

        NAME=$(basename "$FILE")

        # Remove extension
        NAME="${NAME%.*}"

        # Remove common leading track number
        NAME=$(printf '%s' "$NAME" | sed -E 's/^[0-9]+[._ -]+//')

        printf '%s' "$NAME"
        exit 0
    fi
fi


# ============================================================
# Other MPRIS players
# ============================================================

TITLE=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)
ARTIST=$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null)

ARTIST="${ARTIST#[}"
ARTIST="${ARTIST%]}"

if [[ -n "$TITLE" && -n "$ARTIST" ]]; then
    printf '%s — %s' "$TITLE" "$ARTIST"
elif [[ -n "$TITLE" ]]; then
    printf '%s' "$TITLE"
elif [[ -n "$ARTIST" ]]; then
    printf '%s' "$ARTIST"
else
    printf 'No Media Playing'
fi
