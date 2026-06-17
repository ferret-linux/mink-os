#!/usr/bin/env bash
# Install, upgrade, or remove OpenTabletDriver
# @tags: hardware
# @info
#   Install, upgrade, or remove OpenTabletDriver, an open-source
#   user-mode driver supporting a wide range of drawing tablets.
#
#   Fetches the latest release from GitHub, extracts udev rules and the
#   systemd user service from the tarball, and installs the app via Flatpak.
#
#   Do not run as root — sudo is used internally for system changes.
#   A reboot is recommended after install or uninstall.
set -euo pipefail

command -v curl      &>/dev/null || { echo "✗  curl required"     >&2; exit 1; }
command -v tar       &>/dev/null || { echo "✗  tar required"      >&2; exit 1; }
command -v flatpak   &>/dev/null || { echo "✗  flatpak required"  >&2; exit 1; }
command -v systemctl &>/dev/null || { echo "✗  systemd required"  >&2; exit 1; }

[[ $EUID -eq 0 ]] && { echo "✗  Do not run as root" >&2; exit 1; }
command -v sudo &>/dev/null || { echo "✗  sudo required" >&2; exit 1; }

FLATPAK_ID="net.opentabletdriver.OpenTabletDriver"
UDEV_RULES="/etc/udev/rules.d/70-opentabletdriver.rules"
MODPROBE_CONF="/etc/modprobe.d/blacklist-opentabletdriver.conf"
SERVICE_FILE="$HOME/.config/systemd/user/opentabletdriver.service"

ok()   { printf '✔  %s\n' "$*"; }
warn() { printf '◇  %s\n' "$*"; }
die()  { printf '✗  %s\n' "$*" >&2; exit 1; }
confirm() { printf '%s [y/N]: ' "$1"; read -r a; [[ "$a" =~ ^[Yy] ]]; }

# ── State ─────────────────────────────────────────────────────
FLATPAK_SCOPE="--system"
if   flatpak info --system "$FLATPAK_ID" &>/dev/null; then HAS_FLATPAK=true; FLATPAK_SCOPE="--system"
elif flatpak info --user   "$FLATPAK_ID" &>/dev/null; then HAS_FLATPAK=true; FLATPAK_SCOPE="--user"
else
    HAS_FLATPAK=false
    flatpak remotes --user 2>/dev/null | grep -q flathub && FLATPAK_SCOPE="--user" || true
fi

HAS_UDEV=false;     [[ -f "$UDEV_RULES"    ]] && HAS_UDEV=true
HAS_MODPROBE=false; [[ -f "$MODPROBE_CONF" ]] && HAS_MODPROBE=true
HAS_SERVICE=false;  [[ -f "$SERVICE_FILE"  ]] && HAS_SERVICE=true
HAS_ENABLED=false; systemctl --user is-enabled opentabletdriver.service &>/dev/null && HAS_ENABLED=true || true

COUNT=0
$HAS_FLATPAK  && (( COUNT++ )) || true
$HAS_UDEV     && (( COUNT++ )) || true
$HAS_MODPROBE && (( COUNT++ )) || true
$HAS_SERVICE  && (( COUNT++ )) || true

# ── Status ────────────────────────────────────────────────────
echo ""
$HAS_FLATPAK  && ok "Flatpak package"  || warn "Flatpak package  — not found"
$HAS_UDEV     && ok "udev rules"       || warn "udev rules       — not found"
$HAS_MODPROBE && ok "Module blacklist" || warn "Module blacklist — not found"
$HAS_SERVICE  && ok "Systemd service"  || warn "Systemd service  — not found"
echo ""

# ── Menu ──────────────────────────────────────────────────────
if   (( COUNT == 0 )); then STATE="none"
elif (( COUNT == 4 )); then STATE="full"
else                        STATE="partial"
fi

case "$STATE" in
    none)    opts=("Install" "Exit") ;;
    full)
        VER=$(flatpak info "$FLATPAK_SCOPE" "$FLATPAK_ID" 2>/dev/null | awk -F': ' '/ersion/{print $2; exit}')
        echo "  Installed version: ${VER:-unknown}"; echo ""
        opts=("Upgrade" "Uninstall" "Exit") ;;
    partial)
        echo "  Partial install ($COUNT/4 components)"; echo ""
        opts=("Repair" "Uninstall" "Exit") ;;
esac

for i in "${!opts[@]}"; do printf '  %d)  %s\n' $(( i+1 )) "${opts[$i]}"; done
printf '\n  choose: '; read -r PICK; echo ""
ACTION="${opts[$((PICK-1))]}"

[[ "$ACTION" == "Exit" ]] && { ok "Bye!"; exit 0; }

# ════════════════════════════════════════════════════════════════
#  INSTALL / UPGRADE / REPAIR
# ════════════════════════════════════════════════════════════════
if [[ "$ACTION" =~ ^(Install|Upgrade|Repair)$ ]]; then

    echo "◈  Fetching latest release..."
    API=$(curl -fsSL "https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest") \
        || die "GitHub API request failed"
    VERSION=$(printf '%s' "$API" | grep '"tag_name"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    TARBALL=$(printf '%s' "$API" | grep 'browser_download_url' | grep -i '\.tar\.gz' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$VERSION" && -n "$TARBALL" ]] || die "Could not parse release info"
    ok "Latest: $VERSION"

    TMPDIR="$(mktemp -d)"; trap 'rm -rf -- "$TMPDIR"' EXIT
    curl -fsSL "$TARBALL" | tar --strip-components=1 -xzf - -C "$TMPDIR" || die "Download/extract failed"

    UDEV_SRC=$(find "$TMPDIR" -name '*opentabletdriver.rules' -print -quit)
    if [[ -n "$UDEV_SRC" ]]; then
        sudo install -D -m 644 "$UDEV_SRC" "$UDEV_RULES"
        sudo udevadm control --reload-rules && sudo udevadm trigger
        ok "udev rules → $UDEV_RULES"
    else
        warn "udev rules not found in tarball"
    fi

    if ! $HAS_MODPROBE; then
        warn "Will blacklist hid_uclogic and wacom kernel drivers"
        if confirm "Apply kernel module blacklist?"; then
            printf 'blacklist hid_uclogic\nblacklist wacom\n' | sudo tee "$MODPROBE_CONF" >/dev/null
            ok "Blacklist → $MODPROBE_CONF"
        else
            warn "Blacklist skipped — some tablets may not work"
        fi
    fi

    if $HAS_FLATPAK; then
        flatpak "$FLATPAK_SCOPE" update -y "$FLATPAK_ID" || die "Flatpak upgrade failed"
        ok "Flatpak upgraded"
    else
        flatpak "$FLATPAK_SCOPE" install -y flathub "$FLATPAK_ID" || die "Flatpak install failed"
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
    $HAS_ENABLED \
        && systemctl --user restart opentabletdriver.service && ok "Service restarted" \
        || systemctl --user enable --now opentabletdriver.service && ok "Service enabled"

    trap - EXIT; rm -rf -- "$TMPDIR"
    printf '\n✔  Done — version %s\n' "$VERSION"
    warn "Reboot recommended to apply kernel changes"

# ════════════════════════════════════════════════════════════════
#  UNINSTALL
# ════════════════════════════════════════════════════════════════
elif [[ "$ACTION" == "Uninstall" ]]; then

    confirm "Remove OpenTabletDriver and all components?" || { ok "Cancelled"; exit 0; }
    echo ""

    $HAS_ENABLED  && systemctl --user disable --now opentabletdriver.service && ok "Service disabled"    || true
    $HAS_SERVICE  && { rm -f "$SERVICE_FILE"; systemctl --user daemon-reload; ok "Service file removed"; } || true
    $HAS_FLATPAK  && { flatpak "$FLATPAK_SCOPE" remove -y "$FLATPAK_ID" || die "Flatpak removal failed"; ok "Flatpak removed"; } || true
    $HAS_UDEV     && { sudo rm -f "$UDEV_RULES"; sudo udevadm control --reload-rules; sudo udevadm trigger; ok "udev rules removed"; } || true
    $HAS_MODPROBE && { sudo rm -f "$MODPROBE_CONF"; ok "Blacklist removed"; } || true

    printf '\n✔  Uninstall complete\n'
    warn "Reboot recommended"

fi