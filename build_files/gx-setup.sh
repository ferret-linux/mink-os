#!/bin/bash
set -euxo pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

# Core gaming performance/compositor stack
GAMING_PERFORMANCE=(
  gamemode
  mangohud
  vkBasalt
  gamescope
)

# Storefronts / launchers / compatibility layers
GAMING_PLATFORMS=(
  steam
  lutris
  wine
  winetricks
  protontricks
  bottles
)

# Kernel modules for gaming peripherals/capture (need KERNEL_VERSION expansion)
GAMING_KERNEL_MODULES=(
  "kmod-xone-${KERNEL_VERSION}"
  "kmod-xpadneo-${KERNEL_VERSION}"
  "kmod-new-lg4ff-${KERNEL_VERSION}"
  "kmod-hid-tmff2-${KERNEL_VERSION}"
  "kmod-hid-fanatecff-${KERNEL_VERSION}"
  "kmod-openrazer-${KERNEL_VERSION}"
)

# Matching userspace libs/common packages for the kmods above
GAMING_KMOD_PACKAGES=(
  hid-tmff2
  new-lg4ff
  hid-fanatecff
  xone-kmod-common
  xpadneo-kmod-common
  openrazer-kmod-common
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${GAMING_PERFORMANCE[@]}"
  "${GAMING_PLATFORMS[@]}"
  "${GAMING_KERNEL_MODULES[@]}"
  "${GAMING_KMOD_PACKAGES[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"