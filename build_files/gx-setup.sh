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
  winetricks
  protontricks
)

# Vulkan/DX translation + diagnostics. libvkd3d is the actual package name
# for the DX12-over-Vulkan runtime (verified via repoquery — "vkd3d" alone
# doesn't resolve). vulkan-tools/libva-utils are diagnostic CLIs
# (vulkaninfo, vainfo) commonly requested by users when troubleshooting
# GPU issues.
GAMING_GRAPHICS_EXTRA=(
  libvkd3d
  vulkan-tools
  libva-utils
)

# Low-latency audio routing. pipewire-jack-audio-connection-kit is the
# actual package name (verified via dnf search — "pipewire-jack" alone
# doesn't resolve). Some VR/pro-audio-adjacent titles talk to JACK
# directly instead of PipeWire's native API.
GAMING_AUDIO_EXTRA=(
  pipewire-jack-audio-connection-kit
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

# VR/AR runtime + HMD drivers. monado is the open-source OpenXR runtime
# (headless service, no GUI); openhmd is the driver library for various
# headsets. Both confirmed resolvable via repoquery.
GAMING_VR=(
  monado
  openxr
  openhmd
  monado-vulkan-layers
)

# Lighthouse/SteamVR-base-station tracking (Valve Index, HTC Vive, older
# Vive Pro). Niche vs. GAMING_VR above — only pulls in if you actually
# want lighthouse-tracked headset support. Confirmed resolvable.
GAMING_VR_LIGHTHOUSE=(
  libsurvive
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${GAMING_PERFORMANCE[@]}"
  "${GAMING_PLATFORMS[@]}"
  "${GAMING_GRAPHICS_EXTRA[@]}"
  "${GAMING_AUDIO_EXTRA[@]}"
  "${GAMING_VR[@]}"
  "${GAMING_VR_LIGHTHOUSE[@]}"
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