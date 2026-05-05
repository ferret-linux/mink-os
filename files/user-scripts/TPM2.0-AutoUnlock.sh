#!/usr/bin/env bash
# Configure TPM2 auto-unlock for a LUKS2 encrypted root partition
# @tags: security
# @info
#   Configures TPM2-based auto-unlock for a LUKS2 encrypted partition
#   using systemd-cryptenroll. Works on Fedora, Fedora Atomic
#
#   Detects the LUKS device from kernel boot parameters (rd.luks.uuid)
#   and verifies TPM2 availability via systemd before proceeding.
#
#   Enable flow:
#   - Optionally sets a TPM2 PIN for additional protection
#   - Binds the key to selected PCR registers (default: PCR 7)
#   - Wipes any existing TPM2 slot before re-enrolling
#
#   Disable flow:
#   - Wipes the TPM2 slot from the LUKS partition
#   - Passphrase unlock always remains available as fallback
#
#   PCR reference:
#   - PCR 7  — Secure Boot state (recommended default)
#   - PCR 0  — Firmware / UEFI code
#   - PCR 4  — Bootloader
#
#   Reboot to verify auto-unlock works. The fallback passphrase is never
#   removed and can always be used if TPM2 unlock fails.
set -euo pipefail

[[ $EUID -ne 0 ]] && exec sudo bash "$0" "$@"

die() { printf '✗  %s\n' "$*" >&2; exit 1; }
ok()  { printf '✔  %s\n' "$*"; }

# ── TPM2 check ────────────────────────────────────────────────
[[ -f /sys/class/tpm/tpm0/device/description ]] \
    && printf '◈  TPM: %s\n' "$(< /sys/class/tpm/tpm0/device/description)" \
    || die "No TPM2 device detected"

systemd-analyze has-tpm2 &>/dev/null || die "Systemd TPM2 support not available"

# ── Detect LUKS2 root ─────────────────────────────────────────
RD_LUKS_UUID=$(xargs -n1 -a /proc/cmdline | grep -F 'rd.luks.uuid=' | cut -d= -f2 | sed 's/^luks-//' || true)
[[ -n "${RD_LUKS_UUID:-}" ]] || die "No LUKS root found in kernel parameters"

CRYPT_DISK=$(realpath "/dev/disk/by-uuid/${RD_LUKS_UUID}")
[[ -b "$CRYPT_DISK" ]] || die "Could not find LUKS block device: $CRYPT_DISK"
ok "Root device: $CRYPT_DISK"

# ── Enable / Disable ──────────────────────────────────────────
echo ""
read -rp "  Enable TPM2 auto-unlock? [y/N]: " ENABLE

if [[ "${ENABLE,,}" != "y" ]]; then
    systemd-cryptenroll --wipe-slot=tpm2 "$CRYPT_DISK"
    ok "TPM2 auto-unlock disabled"; exit 0
fi

read -rp "  Set a TPM2 PIN? [y/N]: " USE_PIN
PIN_ARG=(); [[ "${USE_PIN,,}" == "y" ]] && PIN_ARG=("--tpm2-with-pin=yes")

read -rp "  PCRs to bind [default: 7]: " PCR_INPUT
PCRS="${PCR_INPUT:-7}"

# ── Enroll ────────────────────────────────────────────────────
echo ""
systemd-cryptenroll \
    --wipe-slot=tpm2 \
    --tpm2-device=auto \
    --tpm2-pcrs="$PCRS" \
    "${PIN_ARG[@]}" \
    "$CRYPT_DISK"

ok "TPM2 enrolled — device: $CRYPT_DISK | PCRs: $PCRS | PIN: ${USE_PIN:-n}"
printf '◇  Reboot to verify. Fallback passphrase remains available.\n\n'