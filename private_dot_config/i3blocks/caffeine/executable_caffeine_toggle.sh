#!/bin/bash

# Function to get the current DPMS status
get_dpms_status() {
    if xset -q | grep -q "DPMS is Enabled"; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# Function to toggle DPMS
toggle_dpms() {
    STATUS=$(get_dpms_status)
    if [ "$STATUS" = "ON" ]; then
        xset -dpms       # Disable DPMS (prevent sleep)
        xset s off        # Disable screensaver
    else
        xset +dpms       # Enable DPMS (allow sleep)
        xset s on         # Enable screensaver
    fi
}

# Handle click events
if [ "$BLOCK_BUTTON" ]; then
    toggle_dpms
fi

# Get current status
STATUS=$(get_dpms_status)

# Output icon based on status
if [ "$STATUS" = "OFF" ]; then
    echo "☕"       # Icon when caffeine is active (preventing sleep)
    echo "Caffeine On"
    echo "#FFA500" # Orange color when active
else
    echo "😴"       # Icon when caffeine is inactive (allowing sleep)
    echo "Caffeine Off"
    echo "#FFFFFF" # White color when inactive
fi
