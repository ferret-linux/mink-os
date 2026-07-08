#!/usr/bin/env bash
# @tags: hardware
# @info
#   Install, upgrade, or remove OpenTabletDriver, an open-source
#   user-mode driver for drawing tablets.
#
#   Fetches the latest release from GitHub, installs udev rules and a
#   systemd user service from the tarball, and installs the app via
#   Flatpak. Optionally blacklists conflicting kernel drivers
#   (hid_uclogic, wacom) with confirmation.
#
#   Do not run as root — sudo is used internally for system changes.
#   A reboot is recommended after install or uninstall.

set -euo pipefail
[[ $EUID -eq 0 ]] && { echo "✗  Do not run as root" >&2; exit 1; }

FLATPAK_ID="net.opentabletdriver.OpenTabletDriver"
UDEV_RULES="/etc/udev/rules.d/70-opentabletdriver.rules"
MODPROBE_CONF="/etc/modprobe.d/blacklist-opentabletdriver.conf"
SERVICE_FILE="$HOME/.config/systemd/user/opentabletdriver.service"

ok()   { gum style --foreground 82  "✔  $*"; }
warn() { gum style --foreground 214 "◇  $*"; }
die()  { gum style --foreground 196 "✗  $*" >&2; exit 1; }

# ── State ─────────────────────────────────────────────────────
FLATPAK_SCOPE="--system"
if flatpak info --system "$FLATPAK_ID" &>/dev/null; then
    HAS_FLATPAK=true; FLATPAK_SCOPE="--system"
elif flatpak info --user "$FLATPAK_ID" &>/dev/null; then
    HAS_FLATPAK=true; FLATPAK_SCOPE="--user"
else
    HAS_FLATPAK=false
    flatpak remotes --user 2>/dev/null | grep -q flathub && FLATPAK_SCOPE="--user"
fi

HAS_UDEV=false;     [[ -f "$UDEV_RULES"    ]] && HAS_UDEV=true
HAS_MODPROBE=false; [[ -f "$MODPROBE_CONF" ]] && HAS_MODPROBE=true
HAS_SERVICE=false;  [[ -f "$SERVICE_FILE"  ]] && HAS_SERVICE=true
HAS_ENABLED=false
systemctl --user is-enabled opentabletdriver.service &>/dev/null && HAS_ENABLED=true

COUNT=0
for flag in "$HAS_FLATPAK" "$HAS_UDEV" "$HAS_MODPROBE" "$HAS_SERVICE"; do
    [[ "$flag" == true ]] && (( COUNT++ ))
done

# ── Status ────────────────────────────────────────────────────
gum style --border rounded --margin "1 0" --padding "0 2" --border-foreground 212 "OpenTabletDriver Manager"

if $HAS_FLATPAK;  then ok "Flatpak package";  else warn "Flatpak package  — not found"; fi
if $HAS_UDEV;     then ok "udev rules";       else warn "udev rules       — not found"; fi
if $HAS_MODPROBE; then ok "Module blacklist"; else warn "Module blacklist — not found"; fi
if $HAS_SERVICE;  then ok "Systemd service";  else warn "Systemd service  — not found"; fi
echo

# ── Menu ──────────────────────────────────────────────────────
if   (( COUNT == 0 )); then STATE=none
elif (( COUNT == 4 )); then STATE=full
else                        STATE=partial
fi

case "$STATE" in
    none) opts=("Install" "Exit") ;;
    full)
        VER=$(flatpak info "$FLATPAK_SCOPE" "$FLATPAK_ID" 2>/dev/null | awk -F': ' '/ersion/{print $2; exit}')
        info=$(gum style --foreground 111 "Installed version: ${VER:-unknown}")
        echo "$info"; echo
        opts=("Upgrade" "Uninstall" "Exit") ;;
    partial)
        gum style --foreground 111 "Partial install ($COUNT/4 components)"; echo
        opts=("Repair" "Uninstall" "Exit") ;;
esac

ACTION=$(gum choose "${opts[@]}")
echo
[[ "$ACTION" == "Exit" ]] && { ok "Bye!"; exit 0; }

# ════════════════════════════════════════════════════════════════
#  INSTALL / UPGRADE / REPAIR
# ════════════════════════════════════════════════════════════════
if [[ "$ACTION" =~ ^(Install|Upgrade|Repair)$ ]]; then

    API=$(gum spin --spinner dot --title "Fetching latest release..." --show-output -- \
        curl -fsSL "https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest") \
        || die "GitHub API request failed"
    VERSION=$(printf '%s' "$API" | grep '"tag_name"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    TARBALL=$(printf '%s' "$API" | grep 'browser_download_url' | grep -i '\.tar\.gz' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$VERSION" && -n "$TARBALL" ]] || die "Could not parse release info"
    ok "Latest: $VERSION"

    TMPDIR="$(mktemp -d)"; trap 'rm -rf -- "$TMPDIR"' EXIT
    gum spin --spinner dot --title "Downloading $VERSION..." -- \
        bash -c "curl -fsSL '$TARBALL' | tar --strip-components=1 -xzf - -C '$TMPDIR'" || die "Download/extract failed"

    UDEV_SRC=$(find "$TMPDIR" -name '*opentabletdriver.rules' -print -quit)
    if [[ -n "$UDEV_SRC" ]]; then
        sudo install -D -m 644 "$UDEV_SRC" "$UDEV_RULES"
        sudo udevadm control --reload-rules && sudo udevadm trigger
        ok "udev rules → $UDEV_RULES"
    else
        warn "udev rules not found in tarball"
    fi

    if ! $HAS_MODPROBE; then
        warn "This will blacklist the hid_uclogic and wacom kernel drivers"
        if gum confirm "Apply kernel module blacklist?"; then
            printf 'blacklist hid_uclogic\nblacklist wacom\n' | sudo tee "$MODPROBE_CONF" >/dev/null
            ok "Blacklist → $MODPROBE_CONF"
        else
            warn "Blacklist skipped — some tablets may not work"
        fi
    fi

    if $HAS_FLATPAK; then
        gum spin --spinner dot --title "Upgrading Flatpak..." -- flatpak "$FLATPAK_SCOPE" update -y "$FLATPAK_ID" || die "Flatpak upgrade failed"
        ok "Flatpak upgraded"
    else
        gum spin --spinner dot --title "Installing Flatpak..." -- flatpak "$FLATPAK_SCOPE" install -y flathub "$FLATPAK_ID" || die "Flatpak install failed"
        ok "Flatpak installed"
    fi

    mkdir -p "$HOME/.config/systemd/user"
    SVC_SRC=$(find "$TMPDIR" -name 'opentabletdriver.service' -print -quit)
    if [[ -n "$SVC_SRC" ]]; then
        install -D -m 644 "$SVC_SRC" "$SERVICE_FILE"
    else
        curl -fsSL "https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service" \
            -o "$SERVICE_FILE" || die "Failed to fetch service file"
    fi
    systemctl --user daemon-reload

    if $HAS_ENABLED; then
        systemctl --user restart opentabletdriver.service
        ok "Service restarted"
    else
        systemctl --user enable --now opentabletdriver.service
        ok "Service enabled"
    fi

    trap - EXIT; rm -rf -- "$TMPDIR"
    ok "Done — version $VERSION"
    warn "Reboot recommended to apply kernel changes"

# ════════════════════════════════════════════════════════════════
#  UNINSTALL
# ════════════════════════════════════════════════════════════════
elif [[ "$ACTION" == "Uninstall" ]]; then

    gum confirm "Remove OpenTabletDriver and all components?" || { ok "Cancelled"; exit 0; }
    echo

    if $HAS_ENABLED; then
        systemctl --user disable --now opentabletdriver.service
        ok "Service disabled"
    fi
    if $HAS_SERVICE; then
        rm -f "$SERVICE_FILE"
        systemctl --user daemon-reload
        ok "Service file removed"
    fi
    if $HAS_FLATPAK; then
        flatpak "$FLATPAK_SCOPE" remove -y "$FLATPAK_ID" || die "Flatpak removal failed"
        ok "Flatpak removed"
    fi
    if $HAS_UDEV; then
        sudo rm -f "$UDEV_RULES"
        sudo udevadm control --reload-rules && sudo udevadm trigger
        ok "udev rules removed"
    fi
    if $HAS_MODPROBE; then
        sudo rm -f "$MODPROBE_CONF"
        ok "Blacklist removed"
    fi

    ok "Uninstall complete"
    warn "Reboot recommended"

fi