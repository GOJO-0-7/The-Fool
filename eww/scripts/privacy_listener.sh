#!/bin/bash
# Mic and Screen Record Privacy Monitor

while true; do
  # Check if microphone output source is actively used via pactl
  if pactl list source-outputs | grep -q "Source Output"; then
    mic_used="true"
  else
    mic_used="false"
  fi

  # Check if Screen recording apps are running
  if pgrep -x "obs" >/dev/null || pgrep -x "gpu-screen-recorder" >/dev/null || pgrep -x "wf-recorder" >/dev/null; then
    rec_used="true"
  else
    rec_used="false"
  fi

  eww update mic_active=$mic_used rec_active=$rec_used
  sleep 2
done
