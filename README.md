<div align="center">

<img src=".github/assets/logo.png" alt="TheOneDots" width="180" />

# TheOneDots

**My Linux dotfiles — i3 · Alacritty · tmux · Zsh · Neovim · Claude Code**

Managed with [chezmoi](https://www.chezmoi.io). One command to go from a fresh
Ubuntu box to my full setup — desktop, terminal, editor, and tooling — with a
consistent [Cyberdream](https://github.com/scottmckendry/cyberdream.nvim)
theme throughout and **secrets that can never reach this repo**.

![Made with chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-2563eb)
![Platform](https://img.shields.io/badge/platform-Linux%20(i3%2FX11)-16181a)
![Theme](https://img.shields.io/badge/theme-cyberdream-5ef1ff)
![License](https://img.shields.io/badge/license-MIT-5eff6c)

</div>

---

## ⚡ Install

On a fresh machine, this single command installs chezmoi, pulls this repo,
installs every dependency, and applies all configs:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply shaunbarney
```

> Already have chezmoi? Just `chezmoi init --apply shaunbarney`.

The bootstrap is **idempotent** — safe to run again any time. Preview exactly
what it would change first with:

```sh
chezmoi init shaunbarney      # clone only
chezmoi diff                  # see every pending change
chezmoi apply -v              # apply
```

## 🧩 What's inside

| Area | Tool | Highlights |
|------|------|-----------|
| **WM** | i3 + i3status-rust + i3blocks | tiling, Rust status bar, custom widgets, ultrawide screen-layout + picom watchdog on startup |
| **Terminal** | Alacritty | GPU-accelerated, Cyberdream, JetBrains Mono Nerd Font |
| **Multiplexer** | tmux | XDG layout, Cyberdream statusline, vim-style nav |
| **Shell** | Zsh + Powerlevel10k | instant prompt, modern CLI aliases |
| **Editor** | Neovim 0.12 | lazy.nvim, native **Claude Code**, LSP/DAP/treesitter, Cyberdream |
| **AI** | Claude Code | settings, custom `cyberdream` theme, statusline |
| **Compositor** | picom | NVIDIA-tuned (no fullscreen freeze on X11) |
| **Notifications** | dunst | Cyberdream-matched |
| **Misc** | btop · rofi · git | themed system monitor, launcher, git config |

Everything shares one palette — `bg #16181a · fg #ffffff · red #ff6e5e ·
green #5eff6c · cyan #5ef1ff` — across the editor, terminal, multiplexer,
notifications, and Claude.

## 🖥️ OS support & dependencies

Target: **Ubuntu / Debian on i3 (X11).** The bootstrap detects the OS and:

- installs desktop + CLI packages via `apt`
  (`i3`, `alacritty`, `tmux`, `zsh`, `ripgrep`, `fd`, `fzf`, `bat`, `btop`, …);
- installs tools apt ships stale or not at all from upstream
  (**Neovim 0.12**, `eza`, `lazygit`, `gh`, `chezmoi`);
- installs language toolchains the Neovim LSPs need (`node`, `uv`, `rustup`);
- installs the **JetBrains Mono Nerd Font**.

On non-Debian Linux it applies the configs and prints the package list to
install manually. On non-Linux it applies what it can and skips the desktop.

See [`run_once_before_10-install-packages.sh.tmpl`](run_once_before_10-install-packages.sh.tmpl).

## 🔐 Secrets — they never live here

Real API keys live **only** in `~/.config/zsh/secrets.zsh` (chmod 600), which
is **not** managed by chezmoi and is git-ignored three ways over:

1. `.chezmoiignore` excludes it from management.
2. `.gitignore` blocks any stray `secrets.zsh`.
3. A **pre-commit hook** ([`.githooks/pre-commit`](.githooks/pre-commit),
   active on every clone via `core.hooksPath`) scans staged changes with
   `gitleaks` (or a regex fallback) and **hard-blocks** any commit containing a
   key, token, or private key.

The repo ships only
[`secrets.zsh.example`](private_dot_config/zsh/secrets.zsh.example) with the
variable **names** (no values). On a new machine the bootstrap seeds a real
`secrets.zsh` from it for you to fill in. `~/.zshrc` sources it if present;
i3blocks widgets read the same vars via `secret_loader.py`.

## 🗂️ Layout

```
.
├── dot_zshrc, dot_zshenv, …        → ~/.zshrc, ~/.zshenv, …
├── dot_gitconfig                   → ~/.gitconfig
├── dot_claude/                     → ~/.claude/ (settings, theme, statusline)
├── private_dot_config/
│   ├── nvim/                       → ~/.config/nvim/   (lazy.nvim, Lua)
│   ├── i3/  i3blocks/  i3_startup/ → ~/.config/i3*/
│   ├── alacritty/  tmux/  rofi/    → terminal stack
│   ├── dunst/  btop/  picom.conf   → desktop bits
│   └── zsh/secrets.zsh.example     → key template (never the real keys)
├── run_once_before_*.sh.tmpl       → dependency bootstrap
├── run_once_after_*.sh.tmpl        → default shell + Neovim plugin sync
└── .githooks/pre-commit            → secret scanner
```

chezmoi's `dot_` → `.`, `private_` → `0700`, and `executable_` → `+x` naming
makes it obvious what each file becomes.

## 🔧 Day-to-day

```sh
chezmoi edit ~/.zshrc      # edit a managed file (in the source repo)
chezmoi diff               # what's changed vs. applied
chezmoi apply -v           # apply changes
chezmoi cd                 # jump into the source repo
chezmoi re-add             # pull live edits back into the repo
chezmoi update             # git pull + apply (sync another machine)
```

Aliases in `~/.zshrc`: `cm`, `cme`, `cma`, `cmd`, `cmcd`, `cmap`.

---

<div align="center">
<sub>Built for an Ubuntu 22.04 / i3 / NVIDIA ultrawide setup. MIT licensed — borrow anything.</sub>
</div>
