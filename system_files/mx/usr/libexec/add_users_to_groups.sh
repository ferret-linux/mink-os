#!/usr/bin/env bash
# ================================================================
#  Groups — append all human users to system groups
#  Ferret Project : github.com/ferret-project
# ================================================================
set -euo pipefail

# ── CONFIG — add or remove groups here as needed ──────────────
GROUPS_TO_ADD=(
    gamemode    # gamemode needs it
    kvm         # kernel virtual machine
    docker      # docker access
    plugdev     # openrazer needs it
    libvirt     # kvm/libvirt needs it
    i2c         # low-latency peripherals
    incus       # basic Incus options
    incus-admin # full Incus options
)
UID_MIN=1000
UID_MAX=60000   # exclusive — effective human range: 1000–59999

[[ "$EUID" -ne 0 ]] && { echo "Please run this script as root (sudo $0)" >&2; exit 1; }

# ── Collect human users (real UID range, excluding non-login shells) ──
mapfile -t USERS < <(awk -F: -v min="$UID_MIN" -v max="$UID_MAX" \
    '$3>=min && $3<max && $7!~/(nologin|false|sync)$/ {print $1}' /etc/passwd)

if [[ "${#USERS[@]}" -eq 0 ]]; then
    echo "No human users found — nothing to do."
    exit 0
fi
echo "Users found: ${USERS[*]}"

# ── Apply groups ──────────────────────────────────────────────
for group in "${GROUPS_TO_ADD[@]}"; do
    if ! getent group "$group" &>/dev/null; then
        echo "Group '${group}' not found — skipping"
        continue
    fi
    for user in "${USERS[@]}"; do
        if id -nG -- "$user" | grep -qw "$group"; then
            echo "${user} already in ${group} — skipping"
        else
            usermod -aG "$group" "$user"
            echo "Added ${user} -> ${group}"
        fi
    done
done

echo "Done — changes take effect on next login."