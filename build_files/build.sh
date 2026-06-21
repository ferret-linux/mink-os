#!/bin/bash

set -ouex pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS=(
    "base.sh"
    "kmods.sh"
    "kvm.sh"
    "locales.sh"
)

if [[ "${IMAGE_NAME:-}" == *"nvidia"* ]]; then
    SCRIPTS+=("nvidia.sh")
fi

TOTAL=${#SCRIPTS[@]}

for i in "${!SCRIPTS[@]}"; do
    SCRIPT="${SCRIPTS[$i]}"
    NUM=$((i + 1))

    echo "  ·  [$NUM/$TOTAL]  $SCRIPT"

    if bash "$DIR/$SCRIPT"; then
        echo "     ✓  done"
    else
        echo "     ✗  failed — stopping"
        exit 1
    fi
done

echo ""
echo "  ✓  all done"