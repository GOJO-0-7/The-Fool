#!/usr/bin/env bash

DIR="/mnt/Media/WALL PAPERS"
INTERVAL=700

# Start wallpaper daemon if not running
# (Note: if 'awww' was a typo for 'swww', change it here and below)
if ! pgrep -x "awww-daemon" >/dev/null; then
  awww-daemon &
  sleep 2
fi

# Transition types
TRANSITION_TYPES=("outer" "grow" "wave" "wipe" "center")

# Gracefully handle script exit
trap "echo 'Slideshow stopped.'; exit 0" SIGINT SIGTERM

while true; do
  # 1. Safely load and shuffle all images into an array using null-separators.
  # This prevents errors if filenames contain weird characters or newlines.
  mapfile -d '' -t IMAGES < <(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) -print0 | shuf -z)

  # 2. Check if the folder is empty to prevent infinite fast-looping errors
  if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "No images found in $DIR. Retrying in 60s..."
    sleep 60
    continue
  fi

  # 3. Loop through the array
  for img in "${IMAGES[@]}"; do
    if [ -f "$img" ]; then

      # Select random transition
      RAND_TYPE=${TRANSITION_TYPES[$RANDOM % ${#TRANSITION_TYPES[@]}]}

      # Set Wallpaper
      awww img "$img" \
        --transition-type "$RAND_TYPE" \
        --transition-fps 60 \
        --transition-step 90 \
        --transition-duration 2

      # Run Pywal
      # The '2>/dev/null' at the end silently discards the ImageMagick 'convert' warning
      wal -i "$img" -n -q 2>/dev/null

      sleep "$INTERVAL"
    fi
  done
done
