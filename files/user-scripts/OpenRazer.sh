#!/usr/bin/env bash
# Manage Polychromatic (Flatpak) and OpenRazer daemon
# @tags: hardware
# @info
#   Manages Polychromatic and the OpenRazer daemon for Razer peripheral
#   RGB control and configuration on Linux.
#
#   Polychromatic is a graphical frontend for OpenRazer, installed via
#   Flathub. The OpenRazer daemon runs as a systemd user service and
#   communicates with kernel drivers to control Razer hardware.
#
#   Flathub is added automatically if not already configured.
#
#   Note: openrazer-daemon must be installed on the host via your
#   package manager (it's preinstalled on all our distros)
set -euo pipefail

command -v flatpak   &>/dev/null || { echo "✗  flatpak required"  >&2; exit 1; }
command -v systemctl &>/dev/null || { echo "✗  systemctl required" >&2; exit 1; }

POLY_ID="app.polychromatic.controller"
POLY_NAME="Polychromatic"
DAEMON="openrazer-daemon.service"

ok()   { printf '✔  %s\n' "$*"; }
warn() { printf '◇  %s\n' "$*"; }
die()  { printf '✗  %s\n' "$*" >&2; exit 1; }

# ── State ─────────────────────────────────────────────────────
poly_installed() { flatpak --user info "$POLY_ID" &>/dev/null || flatpak --system info "$POLY_ID" &>/dev/null; }
has_flathub()    { flatpak --user remote-list 2>/dev/null | grep -q flathub || flatpak --system remote-list 2>/dev/null | grep -q flathub; }
daemon_enabled() { systemctl --user is-enabled "$DAEMON" &>/dev/null; }
daemon_active()  { systemctl --user is-active  "$DAEMON" &>/dev/null; }

# ── Status ────────────────────────────────────────────────────
echo ""
has_flathub      && ok "Flathub"                    || warn "Flathub missing"
poly_installed   && ok "$POLY_NAME installed"        || warn "$POLY_NAME not installed"
daemon_enabled   && {
    daemon_active && ok "$DAEMON (running)" || warn "$DAEMON (stopped)"
} || warn "$DAEMON disabled"
echo ""

# ── Helpers ───────────────────────────────────────────────────
confirm() { printf '%s [y/N]: ' "$1"; read -r a; [[ "$a" =~ ^[Yy] ]]; }

ensure_flathub() {
    has_flathub && return
    flatpak --user remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo && ok "Flathub added" || die "Failed to add Flathub"
}

install_poly() {
    poly_installed && { ok "$POLY_NAME already installed"; return; }
    ensure_flathub
    local scope="--user"
    flatpak --system remote-list 2>/dev/null | grep -q flathub && scope="--system"
    flatpak install -y "$scope" flathub "$POLY_ID" && ok "$POLY_NAME installed" || warn "Install failed"
}

remove_poly() {
    poly_installed || { ok "$POLY_NAME not installed"; return; }
    flatpak --user   info "$POLY_ID" &>/dev/null && flatpak uninstall -y --user   "$POLY_ID" >/dev/null || true
    flatpak --system info "$POLY_ID" &>/dev/null && flatpak uninstall -y --system "$POLY_ID" >/dev/null || true
    ok "$POLY_NAME removed"
}

enable_daemon() {
    daemon_enabled || systemctl --user enable --now "$DAEMON" && ok "Daemon enabled" || warn "Failed — is openrazer installed?"
    daemon_active  || systemctl --user start "$DAEMON" && ok "Daemon started" || warn "Failed to start daemon"
}

disable_daemon() {
    daemon_enabled && systemctl --user disable --now "$DAEMON" && ok "Daemon disabled" || ok "Daemon already disabled"
}

# ── Menu ──────────────────────────────────────────────────────
if ! poly_installed && ! daemon_enabled; then
    STATE="none"
elif poly_installed && daemon_enabled; then
    STATE="full"
else
    STATE="partial"
fi

case "$STATE" in
    none)    opts=("Setup" "Exit") ;;
    full)    opts=("Reinstall" "Remove" "Exit") ;;
    partial) opts=("Repair" "Reinstall" "Remove" "Exit") ;;
esac

for i in "${!opts[@]}"; do printf '  %d)  %s\n' $(( i+1 )) "${opts[$i]}"; done
printf '\n  choose: '; read -r PICK; echo ""

ACTION="${opts[$((PICK-1))]}"

case "$ACTION" in
    Setup)
        install_poly; enable_daemon ;;
    Repair)
        poly_installed || install_poly; enable_daemon ;;
    Reinstall)
        confirm "Reinstall $POLY_NAME + restart daemon?" || { ok "Cancelled"; exit 0; }
        disable_daemon; remove_poly; install_poly; enable_daemon ;;
    Remove)
        confirm "Remove $POLY_NAME + disable daemon?" || { ok "Cancelled"; exit 0; }
        disable_daemon; remove_poly ;;
    *)
        ok "Bye!"; exit 0 ;;
esac

printf '\n✔  Done\n\n'