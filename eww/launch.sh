#!/usr/bin/env bash

# EWW Daemon
if ! pgrep -x "eww" >/dev/null; then
    eww daemon &
    sleep 1
fi

# Background Scripts Silent Execution
if ! pgrep -f "notifications.py" >/dev/null; then
    PYTHONWARNINGS="ignore" python3 ~/.config/eww/scripts/notifications.py >/dev/null 2>&1 &
fi

if ! pgrep -f "db_dashboard_notifs.py daemon" >/dev/null; then
    PYTHONWARNINGS="ignore" python3 ~/.config/eww/scripts/db_dashboard_notifs.py daemon >/dev/null 2>&1 &
fi

if ! pgrep -f "charger_listener.py" >/dev/null; then
    python3 ~/.config/eww/scripts/charger_listener.py >/dev/null 2>&1 &
fi

# === New Dynamic Island Listeners ===
if ! pgrep -f "workspace_listener.sh" >/dev/null; then
    bash ~/.config/eww/scripts/workspace_listener.sh >/dev/null 2>&1 &
fi

if ! pgrep -f "privacy_listener.sh" >/dev/null; then
    bash ~/.config/eww/scripts/privacy_listener.sh >/dev/null 2>&1 &
fi

if ! pgrep -f "network_bt_listener.sh" >/dev/null; then
    bash ~/.config/eww/scripts/network_bt_listener.sh >/dev/null 2>&1 &
fi


# Active Windows
eww open island_window
eww open dashboard_window
eww open time_calendar
eww open workspaces_window
eww open applauncher_window
