#!/usr/bin/env bash
# Ask a local Ollama model about the Claude Code agent skills.
# Launched in a floating terminal by skills_browser.sh; keeps a small
# REPL open so you can ask follow-ups. Empty question quits.
set -uo pipefail

SKILLS_DIR="$HOME/.claude/skills"
MODEL="llama3.2"

# Make sure the Ollama daemon is up (it isn't a systemd service here).
if ! ollama list >/dev/null 2>&1; then
    echo "Starting Ollama…"
    setsid ollama serve >/dev/null 2>&1 < /dev/null &
    for _ in $(seq 1 20); do ollama list >/dev/null 2>&1 && break; sleep 0.5; done
fi

# Skill index (names + descriptions) = the model's context.
index="$(for f in "$SKILLS_DIR"/*/SKILL.md; do
    awk -F': ' '/^name:/{n=$2} /^description:/{print "- " n ": " $2; exit}' "$f"
done)"

system="You are a concise assistant for a set of local 'agent skill' workflows.
Here is the full index of installed skills:
$index
Answer questions about which skill to use, what a skill does, or how they
relate. Be brief and name specific skills. If asked for detail beyond the
index, say which SKILL.md to open."

q="${1:-}"
while :; do
    if [ -n "$q" ]; then
        printf '\n\033[1;35m❯ %s\033[0m\n\n' "$q"
        ollama run "$MODEL" "$system

Question: $q"
    fi
    printf '\n\033[1;36mask another (Enter to quit):\033[0m '
    IFS= read -r q || break
    [ -z "$q" ] && break
done
