#!/usr/bin/env bash

STATUS=$(playerctl status 2>/dev/null)

if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
    # গান এবং আর্টিস্টের নাম
    INFO=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null)
    
    # নাম অতিরিক্ত বড় হলে কেটে সংক্ষেপ করার জন্য (Max 40 char)
    if [ ${#INFO} -gt 40 ]; then
        INFO="${INFO:0:37}..."
    fi
    
    echo "<span color='#00ffcc'>$INFO</span>"
else
    echo ""
fi
