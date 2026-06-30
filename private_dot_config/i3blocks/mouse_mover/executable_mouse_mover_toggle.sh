#!/bin/bash

# Path to the mouse mover script
MOUSE_MOVER_SCRIPT="$HOME/scripts/mouse_mover/main.py"

# Path to the virtual environment's Python
VENV_PYTHON="$HOME/scripts/mouse_mover/venv/bin/python"

# Function to get the status of the mouse mover
get_status() {
    if pgrep -f "$MOUSE_MOVER_SCRIPT" > /dev/null; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Function to toggle the mouse mover script
toggle_mouse_mover() {
    STATUS=$(get_status)
    if [ "$STATUS" = "ON" ]; then
        # Stop the mouse mover script
        pkill -f "$MOUSE_MOVER_SCRIPT"
    else
        # Start the mouse mover script in the background using the venv Python
        nohup "$VENV_PYTHON" "$MOUSE_MOVER_SCRIPT" >/dev/null 2>&1 &
    fi
}

# If the script is called with the argument "toggle", perform the toggle and exit
if [ "$1" = "toggle" ]; then
    toggle_mouse_mover
    pkill -SIGRTMIN+11 i3blocks
    exit 0
fi

# Handle click events from i3blocks
if [ "$BLOCK_BUTTON" ]; then
    toggle_mouse_mover
    pkill -SIGRTMIN+11 i3blocks
fi

# Get current status
STATUS=$(get_status)

# Output emoji and i3blocks details
if [ "$STATUS" = "ON" ]; then
    echo "🖱️"
    echo "Mouse Mover On"
    echo "#FFA500"
else
    echo "🚫"
    echo "Mouse Mover Off"
    echo "#FFFFFF"
fi
