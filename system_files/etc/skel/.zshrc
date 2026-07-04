# ==============================================================
#  ~/.zshrc — User Zsh configuration
#  Ferret Project : github.com/ferret-project
# ==============================================================

# ── History ───────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ── Keybindings ───────────────────────────────────────────────
bindkey -e

# ── Directory Navigation ──────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ── History Settings ──────────────────────────────────────────
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# ── Correction ────────────────────────────────────────────────
setopt CORRECT

# ── Completion ────────────────────────────────────────────────
autoload -Uz compinit
compinit
