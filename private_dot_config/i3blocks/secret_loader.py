"""Load shell-style `export KEY=value` lines from ~/.config/zsh/secrets.zsh
into os.environ so i3blocks scripts never hardcode API keys (keeps secrets
out of any committed dotfiles). Values already set in the environment win.
"""
import os


def load_secrets():
    path = os.path.expanduser("~/.config/zsh/secrets.zsh")
    if not os.path.exists(path):
        return
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line.startswith("export ") and "=" in line:
                key, _, val = line[7:].partition("=")
                os.environ.setdefault(key.strip(), val.strip().strip('"').strip("'"))
