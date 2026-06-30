#!/bin/sh

# Set the correct wireless network interface name
INTERFACE="wlxc83a35ac1ebd"

# Get the current Wi-Fi SSID and IP address
WIFI_SSID=$(iwgetid -r)
IP_ADDRESS=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Handle mouse click events
case $BLOCK_BUTTON in
    1) nm-connection-editor & ;;  # Left-click to open Network Manager GUI
    3) nmtui & ;;  # Right-click to open Text-based Network Manager
esac

# Display the network information
if [ -n "$IP_ADDRESS" ]; then
    echo "$WIFI_SSID ($IP_ADDRESS)"
else
    echo "$WIFI_SSID (No IP)"
fi
