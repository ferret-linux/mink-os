#!/usr/bin/env bash
# Switch NetworkManager Wi-Fi backend between iwd and wpa_supplicant
# @tags: system
# @info
#   Toggles NetworkManager's Wi-Fi backend between iwd and wpa_supplicant.
#   Detects the current backend automatically and always switches to the
#   other backend.
#
#   Switching to iwd:
#   - Writes wifi.backend=iwd to /etc/NetworkManager/conf.d/iwd.conf
#   - Disables wpa_supplicant.service (NM manages iwd automatically)
#
#   Switching to wpa_supplicant:
#   - Removes iwd.conf so NM falls back to its default backend
#   - Re-enables and starts wpa_supplicant.service
#
#   All saved Wi-Fi connections are removed since profiles are
#   incompatible between backends. A NetworkManager restart
#   is required to apply the change after switching.
#   Restart with: sudo systemctl restart NetworkManager
set -euo pipefail

[[ $EUID -ne 0 ]] && exec sudo "$0" "$@"

NM_CONF="/etc/NetworkManager/conf.d/iwd.conf"

die()  { printf '✗  %s\n' "$*" >&2; exit 1; }
ok()   { printf '✔  %s\n' "$*"; }
info() { printf '◈  %s\n' "$*"; }

command -v nmcli     &>/dev/null || die "nmcli not found"
command -v systemctl &>/dev/null || die "systemd not found"

# ── Detect current backend ────────────────────────────────────
if [[ -f "$NM_CONF" ]] && grep -q 'wifi.backend=iwd' "$NM_CONF"; then
    CURRENT="iwd"; TARGET="wpa_supplicant"
else
    CURRENT="wpa_supplicant"; TARGET="iwd"
fi

info "Current backend : $CURRENT"
info "Switch to       : $TARGET"
printf '\n  Continue? [y/N]: '
read -r ans; [[ "$ans" =~ ^[Yy] ]] || { info "Cancelled"; exit 0; }
echo

# ── Switch ────────────────────────────────────────────────────
if [[ "$TARGET" == "iwd" ]]; then
    command -v iwctl &>/dev/null || die "iwd is not installed"
    mkdir -p "$(dirname "$NM_CONF")"
    printf '[device]\nwifi.backend=iwd\n' > "$NM_CONF"
    systemctl disable --now wpa_supplicant.service 2>/dev/null || true
    ok "Config written → $NM_CONF"
else
    rm -f "$NM_CONF"
    command -v wpa_supplicant &>/dev/null && systemctl enable --now wpa_supplicant.service
    ok "iwd.conf removed — NM will use wpa_supplicant"
fi

# ── Purge saved Wi-Fi connections ─────────────────────────────
n=0
while IFS=: read -r uuid type; do
    [[ "$type" == "802-11-wireless" ]] || continue
    nmcli connection delete uuid "$uuid" &>/dev/null && (( n++ )) || true
done < <(nmcli -t -f UUID,TYPE connection show)
(( n > 0 )) && ok "Removed $n saved Wi-Fi connection(s)" || info "No saved Wi-Fi connections"

printf '\n◈  Restart NM to apply: sudo systemctl restart NetworkManager\n\n'