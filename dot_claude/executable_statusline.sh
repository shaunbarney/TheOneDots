#!/usr/bin/env bash
# Cyberdream powerline status line for Claude Code.
# Reads the status JSON on stdin; renders coloured powerline segments.
export CC_STATUS_INPUT="$(cat)"
PY="$(command -v python3 || echo /usr/bin/python3)"
"$PY" - <<'PYEOF'
import os, json, subprocess

try:
    d = json.loads(os.environ.get("CC_STATUS_INPUT") or "{}")
except Exception:
    d = {}

model = (d.get("model") or {}).get("display_name") or "Claude"
ws    = d.get("workspace") or {}
cwd   = ws.get("current_dir") or d.get("cwd") or os.path.expanduser("~")
home  = os.path.expanduser("~")
dirn  = os.path.basename(cwd.rstrip("/")) or "/"

cw    = d.get("context_window") or {}
ctx   = cw.get("used_percentage") or 0
try: ctx = int(float(ctx))
except Exception: ctx = 0

cost  = (d.get("cost") or {}).get("total_cost_usd") or 0
try: cost = float(cost)
except Exception: cost = 0.0

branch = ""
try:
    r = subprocess.run(["git", "-C", cwd, "branch", "--show-current"],
                       capture_output=True, text=True, timeout=1)
    if r.returncode == 0:
        branch = r.stdout.strip()
except Exception:
    pass

# ── Cyberdream palette (r,g,b) ──────────────────────────────────────
CYAN   = (94, 241, 255)
BLUE   = (94, 161, 255)
MAGENTA= (255, 94, 241)
GREEN  = (94, 255, 108)
YELLOW = (241, 255, 94)
RED    = (255, 110, 94)
PEACH  = (255, 189, 94)
DARK   = (22, 24, 26)      # segment fg (text on bright bg)

ARROW = ""           # powerline right separator
RESET = "\x1b[0m"

def fg(c): return f"\x1b[38;2;{c[0]};{c[1]};{c[2]}m"
def bg(c): return f"\x1b[48;2;{c[0]};{c[1]};{c[2]}m"

# context colour by fill level
ctx_col = GREEN if ctx < 50 else (YELLOW if ctx < 80 else RED)

# segments: (icon, text, bg colour)
segs = [
    ("\U000f06a9", model,       CYAN),     # 󰚩 model
    ("",     dirn,        BLUE),      #  directory
]
if branch:
    segs.append(("", branch, MAGENTA))  #  git branch
segs.append(("\U000f04c5", f"{ctx}%", ctx_col))   # 󱓅 context
segs.append(("", f"{cost:.2f}", PEACH))     #  cost

out = ""
for i, (icon, text, color) in enumerate(segs):
    out += f"{fg(DARK)}{bg(color)} {icon} {text} "
    nxt = segs[i + 1][2] if i + 1 < len(segs) else None
    if nxt:
        out += f"{fg(color)}{bg(nxt)}{ARROW}"
    else:
        out += f"{RESET}{fg(color)}{ARROW}{RESET}"

print(out)
PYEOF
