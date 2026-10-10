#!/usr/bin/env bash

target="$1"

if [ "$target" = "up" ]; then
    # Scroll Up -> Next Workspace
    hyprctl dispatch 'hl.dsp.focus({workspace="e+1"})' 2>/dev/null || hyprctl dispatch workspace e+1
elif [ "$target" = "down" ]; then
    # Scroll Down -> Previous Workspace
    hyprctl dispatch 'hl.dsp.focus({workspace="e-1"})' 2>/dev/null || hyprctl dispatch workspace e-1
else
    # Click -> Go to exact Workspace ID
    hyprctl dispatch 'hl.dsp.focus({workspace="'"$target"'"})' 2>/dev/null || hyprctl dispatch workspace "$target"
fi
