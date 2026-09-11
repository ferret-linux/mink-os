#!/usr/bin/env bash
# @tags: security
# @info
#   Configures TPM2-based auto-unlock for a LUKS2 encrypted root
#   partition using systemd-cryptenroll.
#
#   Detects the LUKS device from kernel boot parameters (rd.luks.uuid)
#   and verifies TPM2 availability via systemd before proceeding.
#   Offers a real Enable / Disable / Cancel choice — no accidental
#   wipe on a stray keypress.
#
#   Enable binds the key to selected PCR registers (default: PCR 7,
#   Secure Boot state) with an optional PIN. Disable wipes the TPM2
#   slot; the fallback passphrase is never removed either way.

set -euo pipefail
[[ $EUID -ne 0 ]] && exec sudo bash "$0" "$@"

ok()   { gum style --foreground 82  "✔  $*"; }
info() { gum style --foreground 111 "◈  $*"; }
warn() { gum style --foreground 214 "◇  $*"; }
die()  { gum style --foreground 196 "✗  $*" >&2; exit 1; }

gum style --border rounded --margin "1 0" --padding "0 2" --border-foreground 212 "TPM2 LUKS Auto-Unlock"

# ── TPM2 check ────────────────────────────────────────────────
if [[ -f /sys/class/tpm/tpm0/device/description ]]; then
    info "TPM: $(< /sys/class/tpm/tpm0/device/description)"
else
    die "No TPM2 device detected"
fi
systemd-analyze has-tpm2 &>/dev/null || die "Systemd TPM2 support not available"

# ── Detect LUKS2 root ─────────────────────────────────────────
RD_LUKS_UUID=$(xargs -n1 -a /proc/cmdline | grep -F 'rd.luks.uuid=' | cut -d= -f2 | sed 's/^luks-//' || true)
[[ -n "${RD_LUKS_UUID:-}" ]] || die "No LUKS root found in kernel parameters"

CRYPT_DISK=$(realpath "/dev/disk/by-uuid/${RD_LUKS_UUID}")
[[ -b "$CRYPT_DISK" ]] || die "Could not find LUKS block device: $CRYPT_DISK"
ok "Root device: $CRYPT_DISK"
echo

# ── Enable / Disable / Cancel ──────────────────────────────────
ACTION=$(gum choose "Enable" "Disable" "Cancel")
echo
[[ "$ACTION" == "Cancel" ]] && { info "Cancelled — no changes made"; exit 0; }

if [[ "$ACTION" == "Disable" ]]; then
    gum confirm "Wipe TPM2 auto-unlock from $CRYPT_DISK?" || { info "Cancelled"; exit 0; }
    systemd-cryptenroll --wipe-slot=tpm2 "$CRYPT_DISK"
    ok "TPM2 auto-unlock disabled"
    exit 0
fi

# ── Enable ────────────────────────────────────────────────────
PIN_ARG=()
gum confirm "Set a TPM2 PIN?" && PIN_ARG=("--tpm2-with-pin=yes")

PCRS=$(gum input --placeholder "7" --prompt "PCRs to bind: ")
PCRS="${PCRS:-7}"

echo
gum spin --spinner dot --title "Enrolling TPM2..." -- \
    systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs="$PCRS" "${PIN_ARG[@]}" "$CRYPT_DISK"

ok "TPM2 enrolled — device: $CRYPT_DISK | PCRs: $PCRS | PIN: $([[ ${#PIN_ARG[@]} -gt 0 ]] && echo yes || echo no)"
warn "Reboot to verify. Fallback passphrase remains available."