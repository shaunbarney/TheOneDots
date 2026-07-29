#!/usr/bin/env bash
# Right-click: toggle the local LLM stack up/down (down frees VRAM instantly).
set -euo pipefail

COMPOSE="$HOME/.local/share/local-llm/docker-compose.yml"

if [[ "$(docker inspect -f '{{.State.Status}}' local-llm-ollama 2>/dev/null)" == "running" ]]; then
    docker compose -f "$COMPOSE" down
else
    docker compose -f "$COMPOSE" up -d
fi
