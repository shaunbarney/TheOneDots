#!/usr/bin/env bash
# Status for the "Bose" block in ~/.config/i3status-rust/config.toml.
# Emits i3status-rust custom-block JSON: green "Bose ✓" while the
# soundbar is connected, dim idle "Bose" otherwise.

mac="$(bluetoothctl devices 2>/dev/null | grep -i bose | head -n1 | awk '{print $2}')"

if [ -n "$mac" ] && bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
    echo '{"icon":"headphones","text":"Bose ✓","state":"Good"}'
else
    echo '{"icon":"headphones","text":"Bose","state":"Idle"}'
fi
