#!/bin/bash

# Set a default value for BLOCK_BUTTON if not already set
BLOCK_BUTTON=${BLOCK_BUTTON:-0}

# Check if a left click is detected
if [ "$BLOCK_BUTTON" -eq 1 ]; then
    # Run the plot script on left click
    python3 "$HOME/.config/i3blocks/housing/plot.py"
else
    # Run the main script by default
    python3 "$HOME/.config/i3blocks/housing/main.py"
fi
