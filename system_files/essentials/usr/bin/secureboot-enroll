#!/usr/bin/env bash
# @tags: security
# @info
#   Enrolls a Machine Owner Key (MOK) into the Secure Boot pending list
#   using mokutil. Designed for Fedora systems using akmods where a
#   custom signing key is generated at /etc/pki/akmods/certs/.
#
#   Checks first whether the key is already enrolled (confirmed at a
#   prior MOK Manager boot screen). If so, nothing is done unless you
#   confirm you want to re-queue it. Otherwise it enrolls directly —
#   if it's already pending, mokutil reports SKIP and exits cleanly.
#
#   Secure Boot must be enabled for MOK enrollment to have any effect.
set -euo pipefail

MOK="/etc/pki/akmods/certs/ferret-mok.der"
PASSWORD="ferret"

sudo test -f "$MOK" || { echo "✗  MOK file not found: $MOK" >&2; exit 1; }

# ── Already enrolled? ────────────────────────────────────────
TEST=$(sudo mokutil --test-key "$MOK" 2>&1)

if [[ "$TEST" == *"is already enrolled"* ]]; then
    printf '✔  Key already enrolled — Secure Boot trusts it, nothing to do\n'
    gum confirm "Re-queue it in the pending list anyway?" || exit 0
    echo
fi

# ── Enroll (or re-queue) ──────────────────────────────────────
OUT=$(printf '%s\n%s\n' "$PASSWORD" "$PASSWORD" | sudo mokutil --import "$MOK" 2>&1) || true

if [[ "$OUT" == *"SKIP:"* ]]; then
    printf '◇  Key already pending — no changes made\n'
else
    printf '✔  MOK enrollment queued\n'
fi

printf '
  Next steps:
  1) Reboot
  2) Select "Enroll MOK" in the MOK menu
  3) Enter password: %s
  4) Confirm and reboot\n\n' "$PASSWORD"