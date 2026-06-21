#!/usr/bin/env bash
# ================================================================
#  Groups — append all human users to system groups
#  Ferret Project : github.com/ferret-project
# ================================================================
# ── Exit immediately if a command exits with a non-zero status ── #
set -euo pipefail
# ── Styling ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'
say()  { printf '%b\n' "$*"; }
info() { say "${CYAN}◈${NC}  $*"; }
ok()   { say "${GREEN}◆${NC}  $*"; }
warn() { say "${YELLOW}◇${NC}  $*"; }
fail() { say "${RED}⦻${NC}  $*" >&2; exit 1; }
# ── Header ────────────────────────────────────────────────────
say ""
say "${MAGENTA}${BOLD}╔══════════════════════════════════════════╗${NC}"
say "${MAGENTA}${BOLD}║   ◈  User Group Manager  ◈               ║${NC}"
say "${MAGENTA}${BOLD}║   append human users to system groups    ║${NC}"
say "${MAGENTA}${BOLD}╚══════════════════════════════════════════╝${NC}"
say ""
# ================================================================
#  CONFIG — add or remove groups here as needed
# ================================================================
GROUPS_TO_ADD=(
    gamemode    # gamemode needs it
    kvm         # kernel virtual machine
    docker      # docker access
    plugdev     # openrazer needs it
    libvirt     # kvm/libvirt needs it
    falcond     # Falcond gamemode needs it
    i2c         # Needed for low latency prepherals
)
# ── UID range that defines a "human" user ─────────────────────
UID_MIN=1000
UID_MAX=60000   # exclusive upper bound  →  effective range: 1000–59999
# ================================================================
# ── Flags ─────────────────────────────────────────────────────
DRY_RUN=false

usage() {
    say "Usage: $(basename "$0") [--dry-run] [--groups \"group1 group2 ...\"]"
    say ""
    say "  --dry-run              Show what would be done without making changes"
    say "  --groups \"g1 g2 ...\"   Override the default group list at runtime"
    say ""
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)   DRY_RUN=true; shift ;;
        --groups)    IFS=' ' read -r -a GROUPS_TO_ADD <<< "$2"; shift 2 ;;
        --help|-h)   usage ;;
        *) fail "Unknown option: $1" ;;
    esac
done

[[ "$DRY_RUN" == true ]] && warn "Dry-run mode — no changes will be made" && say ""
# ── Root check ────────────────────────────────────────────────
[[ "$EUID" -ne 0 ]] && fail "Please run this script as root (sudo $0)"

# ── Collect all human users from /etc/passwd ──────────────────
get_human_users() {
    while IFS=: read -r username _ uid _ _ _ shell; do
        if [[ "$uid" -ge "$UID_MIN" && "$uid" -lt "$UID_MAX" ]]; then
            case "$shell" in
                */nologin|*/false|*/sync) continue ;;
            esac
            echo "$username"
        fi
    done < /etc/passwd
}

# ── Add a single user to a single group ───────────────────────
add_user_to_group() {
    local user="$1" group="$2"
    if id -nG -- "$user" | grep -qw "$group"; then
        warn "${user} is already in '${group}' — skipping"
    elif [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would add ${BOLD}${user}${NC} → ${group}"
    else
        usermod -aG "$group" "$user"
        ok "Added ${BOLD}${user}${NC} ${GREEN}→${NC} ${group}"
    fi
}

# ── Scan for users ────────────────────────────────────────────
info "Scanning for human users (UID ${UID_MIN}–$((UID_MAX - 1)))..."
mapfile -t USERS < <(get_human_users)

if [[ "${#USERS[@]}" -eq 0 ]]; then
    warn "No human users found — nothing to do."
    exit 0
fi
ok "Found user(s): ${USERS[*]}"
say ""

# ── Process each group ────────────────────────────────────────
for group in "${GROUPS_TO_ADD[@]}"; do
    say "${MAGENTA}${BOLD}  ──  ${group}  ────────────────────────────────────${NC}"

    if ! getent group "$group" &>/dev/null; then
        warn "Group '${group}' not found on this system — skipping"
        say ""
        continue
    fi

    for user in "${USERS[@]}"; do
        add_user_to_group "$user" "$group"
    done
    say ""
done

# ── Done ──────────────────────────────────────────────────────
say "${MAGENTA}${BOLD}╔══════════════════════════════════════════╗${NC}"
if [[ "$DRY_RUN" == true ]]; then
say "${MAGENTA}${BOLD}║   ◆  Dry-run Complete — no changes made  ║${NC}"
else
say "${MAGENTA}${BOLD}║   ◆  Group Assignment Complete           ║${NC}"
say "${MAGENTA}${BOLD}║   changes take effect on next login      ║${NC}"
fi
say "${MAGENTA}${BOLD}╚══════════════════════════════════════════╝${NC}"
say ""