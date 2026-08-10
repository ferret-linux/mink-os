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

# compatibility layers
GAMING_PLATFORMS=(
  wine
  openxr
  winetricks
  protontricks
)

# Vulkan/DX translation + diagnostics. vkd3d gives Proton titles DX12-over-
# Vulkan support; vulkan-tools/libva-utils are diagnostic CLIs (vulkaninfo,
# vainfo) commonly requested by users when troubleshooting GPU issues.
GAMING_GRAPHICS_EXTRA=(
  vkd3d
  vulkan-tools
  libva-utils
)

# Steam Runtime host dependencies. steam-devices installs the udev rules
# Steam's controller/VR support relies on; xdg-desktop-portal(-gtk) is what
# Flatpak Steam uses for file pickers and screen capture. None of these
# pull in Steam itself — they just make it work correctly once the user
# installs it on their own.
STEAM_RUNTIME_DEPS=(
  steam-devices
  xdg-desktop-portal
  xdg-desktop-portal-gtk
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
  "${GAMING_GRAPHICS_EXTRA[@]}"
  "${STEAM_RUNTIME_DEPS[@]}"
  "${GAMING_KERNEL_MODULES[@]}"
  "${GAMING_KMOD_PACKAGES[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"

# Note: ntsync (Wine/Proton sync-primitive fast path) is mainline as of
# kernel 6.14+ and does not need a separate kmod package — system_files/gx
# already loads it via modules-load.d/ntsync.conf. Nothing to install here;
# just confirm CONFIG_NTSYNC=y in the running kernel config if sync
# primitives don't show up under /dev/ntsync.