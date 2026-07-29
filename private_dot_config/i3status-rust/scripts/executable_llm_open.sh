#!/usr/bin/env bash
# Left-click: make sure the local LLM stack is up, then open the oterm TUI
# chat in a floating Alacritty window (i3 rule matches instance "llm-chat").
set -euo pipefail

COMPOSE="$HOME/.local/share/local-llm/docker-compose.yml"

if [[ "$(docker inspect -f '{{.State.Status}}' local-llm-ollama 2>/dev/null)" != "running" ]]; then
    docker compose -f "$COMPOSE" up -d ollama
fi

exec alacritty --class llm-chat --title "Local LLM" \
    -e docker compose -f "$COMPOSE" run --rm tui >/dev/null 2>&1
