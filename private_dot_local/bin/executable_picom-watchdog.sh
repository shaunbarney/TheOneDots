#!/usr/bin/env bash
# Singleton watchdog: keeps picom alive forever. Respawns it within ~3s
# of ANY death (crash, restart, manual kill). Launched from i3 autostart.

# Kill any older instance of this watchdog (keep only this newest one).
for pid in $(pgrep -f "[p]icom-watchdog.sh"); do
  [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null
done

# Clean restart of picom (avoids the "another compositor running" race).
pkill -x picom 2>/dev/null
sleep 1

while true; do
  if ! pgrep -x picom >/dev/null; then
    picom --config "$HOME/.config/picom.conf" >/dev/null 2>&1 &
  fi
  sleep 3
done
