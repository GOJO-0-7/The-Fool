#!/usr/bin/env bash
profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")
echo $profile
