#!/usr/bin/env bash

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo "{\"enabled\": true, \"icon\": \"󰂯\", \"status\": \"On\"}"
else
    echo "{\"enabled\": false, \"icon\": \"󰂲\", \"status\": \"Off\"}"
fi
