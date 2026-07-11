#!/usr/bin/env bash
# @tags: hardware
# @info
#   Manages Polychromatic and the OpenRazer daemon for Razer peripheral
#   RGB control on Linux.
#
#   Polychromatic is a graphical frontend for OpenRazer, installed via
#   Flatpak (Flathub is added automatically if missing). OpenRazer
#   itself runs as a systemd user service talking to the kernel driver.
#
#   Detects current install state and offers Setup / Repair / Reinstall
#   / Remove accordingly. Note: openrazer-daemon must already be
#   installed on the host via your package manager.

set -euo pipefail

POLY_ID="app.polychromatic.controller"
POLY_NAME="Polychromatic"
DAEMON="openrazer-daemon.service"

ok()   { gum style --foreground 82  "✔  $*"; }
warn() { gum style --foreground 214 "◇  $*"; }

poly_installed() { flatpak --user info "$POLY_ID" &>/dev/null || flatpak --system info "$POLY_ID" &>/dev/null; }
has_flathub()    { flatpak --user remote-list 2>/dev/null | grep -q flathub || flatpak --system remote-list 2>/dev/null | grep -q flathub; }
daemon_enabled() { systemctl --user is-enabled "$DAEMON" &>/dev/null; }
daemon_active()  { systemctl --user is-active  "$DAEMON" &>/dev/null; }

ensure_flathub() {
    has_flathub && return
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    ok "Flathub added"
}

install_poly() {
    if poly_installed; then ok "$POLY_NAME already installed"; return; fi
    ensure_flathub
    local scope="--user"
    has_flathub && flatpak --system remote-list 2>/dev/null | grep -q flathub && scope="--system"
    flatpak install -y "$scope" flathub "$POLY_ID"
    ok "$POLY_NAME installed"
}

remove_poly() {
    if ! poly_installed; then ok "$POLY_NAME not installed"; return; fi
    flatpak --user   info "$POLY_ID" &>/dev/null && flatpak uninstall -y --user   "$POLY_ID" >/dev/null
    flatpak --system info "$POLY_ID" &>/dev/null && flatpak uninstall -y --system "$POLY_ID" >/dev/null
    ok "$POLY_NAME removed"
}

enable_daemon() {
    daemon_enabled || systemctl --user enable --now "$DAEMON"
    daemon_active  || systemctl --user start "$DAEMON"
    ok "Daemon enabled"
}

disable_daemon() {
    if daemon_enabled; then
        systemctl --user disable --now "$DAEMON"
        ok "Daemon disabled"
    else
        ok "Daemon already disabled"
    fi
}

# ── Status ────────────────────────────────────────────────────
gum style --border rounded --margin "1 0" --padding "0 2" --border-foreground 212 "Razer / Polychromatic Manager"

if has_flathub; then ok "Flathub"; else warn "Flathub missing"; fi
if poly_installed; then ok "$POLY_NAME installed"; else warn "$POLY_NAME not installed"; fi
if daemon_enabled; then
    if daemon_active; then ok "$DAEMON (running)"; else warn "$DAEMON (stopped)"; fi
else
    warn "$DAEMON disabled"
fi
echo

# ── Menu ──────────────────────────────────────────────────────
if ! poly_installed && ! daemon_enabled; then STATE="none"
elif poly_installed && daemon_enabled;    then STATE="full"
else                                            STATE="partial"
fi

case "$STATE" in
    none)    opts=("Setup" "Exit") ;;
    full)    opts=("Reinstall" "Remove" "Exit") ;;
    partial) opts=("Repair" "Reinstall" "Remove" "Exit") ;;
esac

ACTION=$(gum choose "${opts[@]}")
echo

case "$ACTION" in
    Setup)
        install_poly; enable_daemon ;;
    Repair)
        poly_installed || install_poly; enable_daemon ;;
    Reinstall)
        gum confirm "Reinstall $POLY_NAME + restart daemon?" || { ok "Cancelled"; exit 0; }
        disable_daemon; remove_poly; install_poly; enable_daemon ;;
    Remove)
        gum confirm "Remove $POLY_NAME + disable daemon?" || { ok "Cancelled"; exit 0; }
        disable_daemon; remove_poly ;;
    *)
        ok "Bye!"; exit 0 ;;
esac

echo
ok "Done"