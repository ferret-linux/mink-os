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

# Audio multilib stack (PipeWire/PulseAudio/ALSA compatibility). FAudio is
# Wine's XAudio2 reimplementation — a common cause of missing/broken audio
# under Proton if left out. pulseaudio-libs covers titles that talk to
# PulseAudio directly instead of going through the ALSA/PipeWire shim.
MULTILIB_AUDIO=(
  alsa-lib.i686
  pipewire.i686
  pipewire-alsa.i686
  pulseaudio-libs.i686
  libFAudio.i686
)

# Input handling. sdl2-compat is Fedora's SDL2-API-over-SDL3 runtime — the
# actual installable provider of "SDL2" on current Fedora. Backs controller/
# joystick support in both Wine and a large share of native/Proton titles.
MULTILIB_INPUT=(
  sdl2-compat.i686
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

# Lower-level GPU access + image/compression libs frequently pulled in by
# game engines running inside a Wine prefix. libdrm is usually resolved
# transitively via mesa, but pinned explicitly here rather than relying on
# the resolver — the nvidia.sh multilib break earlier was exactly this kind
# of implicit-dependency failure. zlib-ng-compat is Fedora's current
# drop-in provider for zlib.
MULTILIB_MEDIA=(
  libdrm.i686
  zlib-ng-compat.i686
  libjpeg-turbo.i686
  libpng.i686
)

# Misc runtime deps (compression, fonts, networking) frequently pulled
# in by Wine/Proton prefixes
MULTILIB_MISC=(
  freetype.i686
  fontconfig.i686
  openssl-libs.i686
  gnutls.i686
)

# 32-bit DX12-over-Vulkan translation. libvkd3d is the actual package name
# (Fedora ships the runtime lib as libvkd3d, not vkd3d). libva-utils is
# CLI-only tooling with no i686 build — confirmed via repoquery — so it's
# intentionally NOT duplicated here; the 64-bit copy in gx-setup.sh covers
# diagnostics for both architectures.
MULTILIB_GRAPHICS_EXTRA=(
  libvkd3d.i686
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
  "${MULTILIB_INPUT[@]}"
  "${MULTILIB_X11[@]}"
  "${MULTILIB_MEDIA[@]}"
  "${MULTILIB_MISC[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"