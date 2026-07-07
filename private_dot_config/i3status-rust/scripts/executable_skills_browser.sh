#!/usr/bin/env bash
# Searchable browser for the Claude Code agent skills in ~/.claude/skills.
# Wired to the "Skills" block in ~/.config/i3status-rust/config.toml.
#
#   click → rofi fuzzy menu of every skill (name — description)
#         → pick one  → floating terminal rendering its SKILL.md via glow
#                       (searchable in the pager with /)
#         → "Ask AI…" → question via rofi, answered by a local Ollama
#                       model using the skill index as context.
set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASK_ENTRY="🤖 Ask AI about the skills…"

# Build "name — first sentence of description" lines from each frontmatter.
menu() {
    for f in "$SKILLS_DIR"/*/SKILL.md; do
        name="$(basename "$(dirname "$f")")"
        desc="$(awk -F': ' '/^description:/{print $2; exit}' "$f" | cut -c1-100)"
        printf '%s — %s\n' "$name" "$desc"
    done
}

choice="$( { echo "$ASK_ENTRY"; menu; } | rofi -dmenu -i -p "skills" \
            -theme-str 'window {width: 60%;}' )" || exit 0

if [ "$choice" = "$ASK_ENTRY" ]; then
    q="$(rofi -dmenu -p "ask" -theme-str 'listview {enabled: false;}' \
          -mesg "Question about your agent skills (answered locally by Ollama)")" || exit 0
    [ -n "$q" ] && exec alacritty --class skillsview \
        --title "Skills · Ask AI" -e "$SCRIPTS_DIR/skills_ask.sh" "$q"
    exit 0
fi

skill="${choice%% — *}"
file="$SKILLS_DIR/$skill/SKILL.md"
[ -f "$file" ] && exec alacritty --class skillsview \
    --title "Skill · $skill" -e glow -p "$file"
