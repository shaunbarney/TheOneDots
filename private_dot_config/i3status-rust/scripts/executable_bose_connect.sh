#!/usr/bin/env bash
# Connect to the Bose soundbar over Bluetooth.
#
# Auto-detects the paired/known device whose name contains "Bose"
# (case-insensitive), trusts it (so it auto-reconnects in future), and
# connects. If the soundbar has never been paired, opens blueman-manager
# so you can pair it once — after that this button just works.
#
# Wired up to the "Bose" block in ~/.config/i3status-rust/config.toml.

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -t 4000 "󰂯 Bose Soundbar" "$1"
    true
}

# Find a known device whose name contains "bose".
mac="$(bluetoothctl devices 2>/dev/null | grep -i bose | head -n1 | awk '{print $2}')"

if [ -z "$mac" ]; then
    notify "Not paired yet — opening Bluetooth manager so you can pair it once."
    exec blueman-manager
fi

# Make sure the controller is powered on.
bluetoothctl power on >/dev/null 2>&1

if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
    notify "Already connected."
    exit 0
fi

notify "Connecting…"
bluetoothctl trust "$mac" >/dev/null 2>&1

if bluetoothctl connect "$mac" >/dev/null 2>&1; then
    notify "Connected."
else
    notify "Couldn't connect — opening Bluetooth manager."
    exec blueman-manager
fi
