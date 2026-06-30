#!/bin/bash
#

case $BLOCK_BUTTON in
    1) pavucontrol & ;;  # Left click opens pavucontrol
    3) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;  # Right click toggles mute
    4) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;  # Scroll up increases volume
    5) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;  # Scroll down decreases volume
esac

# Get volume and mute status
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)
MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep 'yes')

if [ "$MUTED" != "" ]; then
    echo "🔇 $VOLUME%"
else
    echo "🔊 $VOLUME%"
fi
