#!/bin/bash
set -euxo pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

BUILD_TOOLS=(
  gcc
  rar
  tar
  zip
  file
  just
  make
  zstd
  wget2
  unzip
  glibc
  rsync
  sqlite
  doxygen
  gcc-c++
  diffstat
  procps-ng
  systemtap
  wget2-libs
  wget2-wget
  patchutils
  subversion
  glibc-devel
  libxcrypt-compat
  pkgconf-pkg-config
)

# Kernel modules (need KERNEL_VERSION expansion, so built dynamically)
KERNEL_MODULES=(
  "kmod-zfs-${KERNEL_VERSION}"
  "kmod-evdi-${KERNEL_VERSION}"
  "kmod-xone-${KERNEL_VERSION}"
  "kmod-kvmfr-${KERNEL_VERSION}"
  "kmod-sc0710-${KERNEL_VERSION}"
  "kmod-xpadneo-${KERNEL_VERSION}"
  "kmod-zenergy-${KERNEL_VERSION}"
  "kmod-hid-tmff2-${KERNEL_VERSION}"
  "kmod-new-lg4ff-${KERNEL_VERSION}"
  "kmod-openrazer-${KERNEL_VERSION}"
  "kmod-v4l2loopback-${KERNEL_VERSION}"
  "kmod-hid-fanatecff-${KERNEL_VERSION}"
  "kernel-devel-matched-${KERNEL_VERSION}"
)

KMOD_PACKAGES=(
  zfs
  sc0710
  libevdi
  libzfs7
  zenergy
  hid-tmff2
  libuutil3
  libzpool7
  new-lg4ff
  libnvpair3
  zfs-dracut
  displaylink
  v4l2loopback
  hid-fanatecff
  python3-pyzfs
  xone-kmod-common
  kvmfr-kmod-common
  xpadneo-kmod-common
  openrazer-kmod-common
)

CD_BLURAY=(
  mkisofs
  cdda2wav
  cdrecord
  libbluray
  schily-libs
  dvd+rw-tools
  libbluray-utils
)

PERF_GAMING=(
  gamemode
  mangohud
  vkBasalt
  gamescope
  scx-tools
  scx-scheds
)

FONTS_LANGPACKS=(
  google-noto-sans-lao-vf-fonts
  google-noto-sans-thai-vf-fonts
  google-noto-sans-khmer-vf-fonts
  google-noto-sans-tamil-vf-fonts
  google-noto-sans-sinhala-vf-fonts
  google-noto-sans-myanmar-vf-fonts
  google-noto-sans-bengali-vf-fonts
  google-noto-sans-armenian-vf-fonts
  google-noto-sans-georgian-vf-fonts
  google-noto-sans-ethiopic-vf-fonts
  google-noto-sans-devanagari-vf-fonts
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${NIX[@]}"
  "${AUDIO[@]}"
  "${GIT_TOOLS[@]}"
  "${CLI_TOOLS[@]}"
  "${CD_BLURAY[@]}"
  "${FIRMWARES[@]}"
  "${SSH_TOOLS[@]}"
  "${FUSE_TOOLS[@]}"
  "${PODMAN_ENV[@]}"
  "${NETWORKING[@]}"
  "${UDEV_RULES[@]}"
  "${CORE_SYSTEM[@]}"
  "${BUILD_TOOLS[@]}"
  "${PERF_GAMING[@]}"
  "${GRAPHICS_GPU[@]}"
  "${CAMERA_VIDEO[@]}"
  "${IMAGE_CODECS[@]}"
  "${FFMPEG_MEDIA[@]}"
  "${KMOD_PACKAGES[@]}"
  "${SHELL_TERMINAL[@]}"
  "${KERNEL_MODULES[@]}"
  "${NETWORK_MANAGER[@]}"
  "${SYSTEM_TOOLS_HW[@]}"
  "${FONTS_LANGPACKS[@]}"
  "${GSTREAMER_PLUGINS[@]}"
  "${PRINTING_SCANNING[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"

# ---------------------------------------------------------------------------
# Nerd Fonts (not dnf packages — downloaded directly)
# ---------------------------------------------------------------------------
NERD_VERSION="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.tag_name')"

curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VERSION}/Hack.tar.xz" \
  -o /tmp/Hack.tar.xz
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VERSION}/NerdFontsSymbolsOnly.tar.xz" \
  -o /tmp/NerdFontsSymbolsOnly.tar.xz

mkdir -p /usr/share/fonts/hack-nerd-font
mkdir -p /usr/share/fonts/nerd-fonts-symbols-only

tar -xf /tmp/Hack.tar.xz -C /usr/share/fonts/hack-nerd-font
tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz -C /usr/share/fonts/nerd-fonts-symbols-only

rm -f /tmp/Hack.tar.xz /tmp/NerdFontsSymbolsOnly.tar.xz
fc-cache -f /usr/share/fonts/