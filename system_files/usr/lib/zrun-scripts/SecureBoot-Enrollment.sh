#!/usr/bin/env bash
# Enroll a MOK key into the Secure Boot pending list
# @tags: security
# @info
#   Enrolls a Machine Owner Key (MOK) into the Secure Boot pending list
#   using mokutil. Designed for Fedora systems using akmods where a
#   custom signing key is generated at /etc/pki/akmods/certs/.
#
#   MOK enrollment is required when Secure Boot is enabled and kernel
#   modules are signed with a local key (e.g. nvidia, v4l2loopback).
#   Without enrollment, signed modules are rejected at boot.
#
#   The key is submitted to the MOK pending list with a preset password.
#   On next reboot, the UEFI MOK Manager prompts for confirmation.
#   If the key is already pending, mokutil reports SKIP and exits cleanly.
#
#   After enrollment is confirmed at the MOK menu, the key persists
#   across reboots and all modules signed with it load without restriction.
#   Secure Boot must be enabled for MOK enrollment to have any effect.
set -euo pipefail

command -v mokutil &>/dev/null || { echo "✗  mokutil required" >&2; exit 1; }

MOK="/etc/pki/akmods/certs/ferret-sb.der"
PASSWORD="ferret"

sudo test -f "$MOK" || { echo "✗  MOK file not found: $MOK" >&2; exit 1; }

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