#!/usr/bin/env bash
# Bar block status for the local LLM stack (Ollama + Open WebUI in Docker).
# States: green = model loaded in VRAM, purple = stack up, dim = stopped.
set -euo pipefail

ICON="󰚩"

state=$(docker inspect -f '{{.State.Status}}' local-llm-ollama 2>/dev/null || echo "absent")

if [[ "$state" != "running" ]]; then
    echo "{\"text\":\"$ICON LLM off\",\"state\":\"Idle\"}"
    exit 0
fi

loaded=$(curl -sf --max-time 2 http://127.0.0.1:11435/api/ps \
    | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4 || true)

if [[ -n "$loaded" ]]; then
    echo "{\"text\":\"$ICON ${loaded%%:*}\",\"state\":\"Good\"}"
else
    echo "{\"text\":\"$ICON LLM\",\"state\":\"Info\"}"
fi
