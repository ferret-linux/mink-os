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

SYSTEM_TOOLS_HW=(
  bolt
  upower
  ddcutil
  fprintd
  usbmuxd
  liquidctl
  fprintd-pam
  brightnessctl
  libratbag-ratbagd
  power-profiles-daemon
)

# Diagnostic/inspection GPU CLIs (not required for HW acceleration itself)
GRAPHICS_GPU_TOOLS=(
  vdpauinfo
  libva-utils
  vulkan-tools
)

FIRMWARES=(
  dvb-firmware
  alsa-firmware
  qcom-firmware
  linux-firmware
  atmel-firmware
  mt7xxx-firmware
  zd1211-firmware
  amd-gpu-firmware
  atheros-firmware
  realtek-firmware
  brcmfmac-firmware
  iwlegacy-firmware
  libertas-firmware
  mediatek-firmware
  tiwilink-firmware
  alsa-sof-firmware
  amd-ucode-firmware
  intel-gpu-firmware
  intel-vsc-firmware
  qcom-wwan-firmware
  nvidia-gpu-firmware
  alsa-tools-firmware
  intel-audio-firmware
  nxpwireless-firmware
  cirrus-audio-firmware
)

UDEV_RULES=(
  solaar-udev
  xr-hardware
  trezor-common
  oversteer-udev
  liquidctl-udev
  mooltipass-udev
  openrgb-udev-rules
  ublue-os-udev-rules
  3dprinter-udev-rules
  python-btchip-common
  unifying-receiver-udev
  system-config-printer-udev
)

# VPN/tunnel clients — protocol/vendor choices, not baseline networking
NETWORKING_VPN=(
  openvpn
  usbguard
  tailscale
  openconnect
  wireguard-tools
  NetworkManager-openvpn
  NetworkManager-openconnect
)

# Extra remote-shell protocol on top of standard SSH
SSH_TOOLS=(
  mosh
)

# Kernel modules (need KERNEL_VERSION expansion, so built dynamically)
KERNEL_MODULES=(
  "kmod-zfs-${KERNEL_VERSION}"
  "kmod-evdi-${KERNEL_VERSION}"
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
  dejavu-sans-fonts
  dejavu-serif-fonts
  google-noto-sans-lao-vf-fonts
  google-noto-sans-thai-vf-fonts
  google-noto-sans-khmer-vf-fonts
  google-noto-sans-tamil-vf-fonts
  google-noto-sans-arabic-vf-fonts
  google-noto-sans-hebrew-vf-fonts
  google-noto-sans-symbols-2-fonts
  google-noto-sans-sinhala-vf-fonts
  google-noto-sans-myanmar-vf-fonts
  google-noto-sans-bengali-vf-fonts
  google-noto-sans-symbols-vf-fonts
  google-noto-sans-armenian-vf-fonts
  google-noto-sans-georgian-vf-fonts
  google-noto-sans-ethiopic-vf-fonts
  google-noto-sans-devanagari-vf-fonts
)

PRINTING_SCANNING=(
  cups
  hplip
  ipp-usb
  nss-mdns
  cups-client
  foomatic-db
  cups-browsed
  cups-filters
  samba-client
  sane-airscan
  sane-backends
  cups-pk-helper
  gutenprint-cups
  system-config-printer
  cups-filters-driverless
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${CD_BLURAY[@]}"
  "${FIRMWARES[@]}"
  "${UDEV_RULES[@]}"
  "${BUILD_TOOLS[@]}"
  "${SSH_TOOLS[@]}"
  "${PERF_GAMING[@]}"
  "${KMOD_PACKAGES[@]}"
  "${KERNEL_MODULES[@]}"
  "${FONTS_LANGPACKS[@]}"
  "${NETWORKING_VPN[@]}"
  "${SYSTEM_TOOLS_HW[@]}"
  "${PRINTING_SCANNING[@]}"
  "${GRAPHICS_GPU_TOOLS[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"