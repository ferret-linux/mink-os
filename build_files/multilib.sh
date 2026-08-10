#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------------------
# multilib.sh — 32-bit (i686) compatibility libraries for gaming.
#
# Runs on *-gx / *-gx-nvidia image variants. Installs the multilib packages
# most Wine/Proton/Steam titles need at runtime (audio, graphics, input,
# compression, etc). No NVIDIA-specific handling here — the 32-bit NVIDIA
# driver/userspace libs are installed from nvidia.sh when the image is also
# an *-nvidia variant.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

# Core C/graphics/windowing multilib runtime
MULTILIB_CORE=(
  glibc.i686
  libgcc.i686
  libstdc++.i686
)

# Graphics/GL/Vulkan multilib stack
MULTILIB_GRAPHICS=(
  mesa-filesystem.i686
  mesa-dri-drivers.i686
  mesa-vulkan-drivers.i686
  mesa-libGL.i686
  mesa-libEGL.i686
  mesa-libgbm.i686
  vulkan-loader.i686
)

# 32-bit builds of gaming overlay/injection tools. gamemode, mangohud, and
# vkBasalt inject into the game's own process, so a 32-bit game needs a
# matching 32-bit copy of these libs to load them — the 64-bit package
# installed in gx-setup.sh isn't enough on its own for 32-bit titles.
MULTILIB_INJECTION=(
  gamemode.i686
  mangohud.i686
  vkBasalt.i686
)

# Audio multilib stack (PipeWire/PulseAudio/ALSA compatibility)
MULTILIB_AUDIO=(
  alsa-lib.i686
  pipewire.i686
  pipewire-alsa.i686
)

# X11 multilib libs commonly required by older/proprietary games
MULTILIB_X11=(
  libX11.i686
  libXext.i686
  libXrandr.i686
  libXcursor.i686
  libXi.i686
  libXinerama.i686
  libXcomposite.i686
  libXfixes.i686
)

# Misc runtime deps (compression, fonts, networking) frequently pulled
# in by Wine/Proton prefixes
MULTILIB_MISC=(
  freetype.i686
  fontconfig.i686
  openssl-libs.i686
  gnutls.i686
)

# 32-bit DX12-over-Vulkan translation + VA-API decode. Many older/32-bit
# Proton titles still need the i686 build of vkd3d specifically; libva-utils
# is small and matches the 64-bit copy added in gx-setup.sh for consistency.
MULTILIB_GRAPHICS_EXTRA=(
  vkd3d.i686
  libva-utils.i686
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${MULTILIB_CORE[@]}"
  "${MULTILIB_GRAPHICS[@]}"
  "${MULTILIB_GRAPHICS_EXTRA[@]}"
  "${MULTILIB_INJECTION[@]}"
  "${MULTILIB_AUDIO[@]}"
  "${MULTILIB_X11[@]}"
  "${MULTILIB_MISC[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"