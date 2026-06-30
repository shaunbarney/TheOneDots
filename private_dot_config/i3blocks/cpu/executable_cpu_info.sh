#!/bin/sh

# Fetch the CPU temperature using the correct sensor labels
TEMP=$(sensors | grep -E 'Tctl|Tccd1' | grep -oE '[0-9]+\.[0-9]+°C' | head -n 1)

# Fetch the CPU usage
CPU_USAGE=$(mpstat 1 1 | awk '/Average:/ {printf("%s", $(NF-9))}')

# Output the CPU usage and temperature
if [ -n "$TEMP" ]; then
  echo "$CPU_USAGE $TEMP" | awk '{ printf("🖥️%6s% @ %s \n", $1, $2) }'
else
  echo "$CPU_USAGE" | awk '{ printf(" 🖥️%6s% \n", $1) }'
fi
