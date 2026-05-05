#!/usr/bin/env bash
# Add/remove users from groups (rpm-ostree/bootc /etc/group workaround)
# @tags: system
# @info
#   Manages user group membership on rpm-ostree/bootc systems such as
#   Fedora Atomic, Silverblue, and Kinoite, where /etc/group may not be
#   pre-populated with groups defined in /usr/lib/group.
#
#   Add mode:
#   - Validates groups against /etc/group and /usr/lib/group
#   - Auto-populates /etc/group from /usr/lib/group when needed
#   - Skips groups the user is already a member of it
#
#   Remove mode:
#   - Lists current group memberships
#   - Removes selected groups via gpasswd
#
#   Input accepts space or comma separated group names.
#   Confirmation is required before any changes are applied.
#   Changes take effect after logging out and back in.
set -euo pipefail

die()  { printf '✗  %s\n' "$*" >&2; exit 1; }
ok()   { printf '✔  %s\n' "$*"; }
confirm() { printf '%s [y/N]: ' "$1"; read -r a; [[ "$a" =~ ^[Yy] ]]; }

group_in_lib() { grep -qE "^$1:" /usr/lib/group 2>/dev/null; }
group_in_etc() { grep -qE "^$1:" /etc/group     2>/dev/null; }
user_in_group() { id -nG "$1" 2>/dev/null | tr ' ' '\n' | grep -qx "$2"; }

# ── User ──────────────────────────────────────────────────────
mapfile -t REAL_USERS < <(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd)

if [[ ${#REAL_USERS[@]} -eq 1 ]]; then
    TARGET_USER="${REAL_USERS[0]}"
    printf '◈  User: %s (auto)\n' "$TARGET_USER"
else
    DEFAULT_USER="${SUDO_USER:-$USER}"
    printf '◈  User [%s]: ' "$DEFAULT_USER"; read -r INPUT_USER
    TARGET_USER="${INPUT_USER:-$DEFAULT_USER}"
fi
id "$TARGET_USER" &>/dev/null || die "User '$TARGET_USER' not found"

# ── Action ────────────────────────────────────────────────────
printf '◈  Action [A/r] (A=add r=remove): '; read -r ACTION_INPUT
[[ "${ACTION_INPUT,,}" == "r" ]] && ACTION="remove" || ACTION="add"

# ── Remove ────────────────────────────────────────────────────
if [[ "$ACTION" == "remove" ]]; then
    printf '◈  Current groups: %s\n' "$(id -nG "$TARGET_USER" | tr ' ' '\n' | sort | tr '\n' ' ')"
    printf '◈  Remove from (space/comma separated): '; read -r GROUP_INPUT
    [[ -n "$GROUP_INPUT" ]] || die "No groups entered"
    IFS=' ,' read -ra RAW_GROUPS <<< "$GROUP_INPUT"

    VALID_GROUPS=()
    for g in "${RAW_GROUPS[@]}"; do
        [[ -z "$g" ]] && continue
        user_in_group "$TARGET_USER" "$g" \
            && VALID_GROUPS+=("$g") && printf '  ✔  %s → queued\n' "$g" \
            || printf '  ✗  %s → not a member\n' "$g"
    done
    [[ ${#VALID_GROUPS[@]} -gt 0 ]] || die "Nothing to remove"

    confirm "Remove $TARGET_USER from: ${VALID_GROUPS[*]}?" || { ok "Cancelled"; exit 0; }

    for g in "${VALID_GROUPS[@]}"; do
        sudo gpasswd -d "$TARGET_USER" "$g" && ok "Removed from $g" || printf '◇  Failed — %s\n' "$g"
    done

# ── Add ───────────────────────────────────────────────────────
else
    printf '◈  Groups to add (space/comma separated): '; read -r GROUP_INPUT
    [[ -n "$GROUP_INPUT" ]] || die "No groups entered"
    IFS=' ,' read -ra RAW_GROUPS <<< "$GROUP_INPUT"

    VALID_GROUPS=(); NEEDS_POPULATE=()
    for g in "${RAW_GROUPS[@]}"; do
        [[ -z "$g" ]] && continue
        if group_in_etc "$g"; then
            printf '  ✔  %s [etc]\n' "$g"
        elif group_in_lib "$g"; then
            printf '  ✔  %s [lib — will populate]\n' "$g"
            NEEDS_POPULATE+=("$g")
        else
            printf '  ✗  %s — not found\n' "$g"; continue
        fi
        VALID_GROUPS+=("$g")
    done
    [[ ${#VALID_GROUPS[@]} -gt 0 ]] || die "No valid groups found"

    confirm "Add $TARGET_USER to: ${VALID_GROUPS[*]}?" || { ok "Cancelled"; exit 0; }

    for g in "${VALID_GROUPS[@]}"; do
        user_in_group "$TARGET_USER" "$g" && { printf '  ↷  %s — already member\n' "$g"; continue; }
        if ! group_in_etc "$g" && group_in_lib "$g"; then
            grep -E "^${g}:" /usr/lib/group | sudo tee -a /etc/group >/dev/null
            ok "Populated $g → /etc/group"
        fi
        sudo usermod -aG "$g" "$TARGET_USER" && ok "Added to $g" || printf '◇  Failed — %s\n' "$g"
    done
fi

printf '\n✔  Done — log out and back in to apply\n'
printf '◈  Verify: id %s\n\n' "$TARGET_USER"