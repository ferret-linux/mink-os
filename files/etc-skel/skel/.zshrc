# ==============================================================
#  ~/.zshrc — User Zsh configuration
#  Ferret Project : github.com/ferret-project
# ==============================================================

# ── History ───────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=4000
SAVEHIST=6000

# ── Keybindings ───────────────────────────────────────────────
bindkey -e

# ── Directory Navigation ──────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ── Correction ────────────────────────────────────────────────
setopt CORRECT

# ── Completion ────────────────────────────────────────────────
autoload -Uz compinit
compinit -C
