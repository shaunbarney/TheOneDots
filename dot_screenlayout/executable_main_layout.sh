#!/bin/sh
# Single-display layout: DP-2 (8K panel) locked at native 7680x2160 @ 120Hz.
# Updated 2026-06-24. Previous multi-monitor version saved as main_layout.sh.bak-2026-06-24.
xrandr \
  --output DP-2 --primary --mode 7680x2160 --rate 120 --pos 0x0 --rotate normal \
  --output HDMI-0 --off \
  --output DP-0 --off \
  --output DP-1 --off \
  --output DP-3 --off \
  --output USB-C-0 --off \
  --output None-1-1 --off
