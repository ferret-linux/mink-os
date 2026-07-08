#!/usr/bin/env bash
# @tags: system
# @info
#   Toggles NetworkManager's Wi-Fi backend between iwd and wpa_supplicant.
#   Detects the configured backend via conf.d/iwd.conf and switches to
#   the other one.
#
#   Shows exactly which saved Wi-Fi networks will be deleted before
#   asking for confirmation — profiles aren't compatible across
#   backends, so all saved networks are wiped and must be reconnected
#   manually afterward.
#
#   NetworkManager restart (required to apply the change) is offered
#   as a separate confirm step, since it may drop the current session.

set -euo pipefail
[[ $EUID -ne 0 ]] && exec sudo "$0" "$@"

NM_CONF="/etc/NetworkManager/conf.d/iwd.conf"

ok()   { gum style --foreground 82  "✔  $*"; }
info() { gum style --foreground 111 "◈  $*"; }
warn() { gum style --foreground 214 "⚠  $*"; }

if [[ -f "$NM_CONF" ]] && grep -q 'wifi.backend=iwd' "$NM_CONF"; then
    CURRENT=iwd; TARGET=wpa_supplicant
else
    CURRENT=wpa_supplicant; TARGET=iwd
fi

gum style --border rounded --margin "1 0" --padding "0 2" --border-foreground 212 "Wi-Fi Backend Switcher"
info "Configured backend now : $(gum style --bold "$CURRENT")"
info "Switching to           : $(gum style --bold "$TARGET")"

mapfile -t WIFI < <(nmcli -t -f UUID,TYPE,NAME connection show | awk -F: '$2=="802-11-wireless"')

if (( ${#WIFI[@]} > 0 )); then
    warn "Saved Wi-Fi networks that will be deleted:"
    for line in "${WIFI[@]}"; do
        gum style --foreground 214 "    • ${line##*:}"
    done
    warn "You'll need to manually reconnect (and re-enter passwords) after."
else
    info "No saved Wi-Fi connections — nothing will be lost."
fi

echo
gum confirm "Switch to $TARGET and delete these networks?" || { info "Cancelled"; exit 0; }
echo

gum spin --spinner dot --title "Applying $TARGET backend..." -- sleep 1

if [[ "$TARGET" == iwd ]]; then
    mkdir -p "$(dirname "$NM_CONF")"
    printf '[device]\nwifi.backend=iwd\n' > "$NM_CONF"
    systemctl disable --now wpa_supplicant.service 2>/dev/null || true
    ok "Config written → $NM_CONF"
else
    rm -f "$NM_CONF"
    systemctl enable --now wpa_supplicant.service
    ok "iwd.conf removed — NM will use wpa_supplicant"
fi

for line in "${WIFI[@]}"; do
    nmcli connection delete uuid "${line%%:*}" &>/dev/null || true
done
(( ${#WIFI[@]} > 0 )) && ok "Removed ${#WIFI[@]} saved Wi-Fi connection(s)"

echo
warn "Restarting NetworkManager may briefly drop your current connection."
if gum confirm "Restart NetworkManager now?"; then
    gum spin --spinner dot --title "Restarting NetworkManager..." -- systemctl restart NetworkManager
    ok "NetworkManager restarted — backend is now $TARGET"
else
    info "Apply later with: sudo systemctl restart NetworkManager"
fi