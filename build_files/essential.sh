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
  "kmod-kvmfr-${KERNEL_VERSION}"
  "kmod-sc0710-${KERNEL_VERSION}"
  "kmod-zenergy-${KERNEL_VERSION}"
  "kmod-v4l2loopback-${KERNEL_VERSION}"
  "kernel-devel-matched-${KERNEL_VERSION}"
)

KMOD_PACKAGES=(
  zfs
  sc0710
  libevdi
  libzfs7
  zenergy
  libuutil3
  libzpool7
  libnvpair3
  zfs-dracut
  displaylink
  v4l2loopback
  python3-pyzfs
  kvmfr-kmod-common
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
  "${BUILD_TOOLS[@]}"
  "${KERNEL_MODULES[@]}"
  "${KMOD_PACKAGES[@]}"
  "${CD_BLURAY[@]}"
  "${PERF_GAMING[@]}"
  "${FONTS_LANGPACKS[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"