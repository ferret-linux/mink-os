#!/bin/bash
set -eoux pipefail

# Build Tools
dnf install -y --setopt=install_weak_deps=False \
  gcc \
  zstd \
  make \
  just \
  glibc \
  patch \
  rsync \
  sqlite \
  gcc-c++ \
  busybox

# Fuse Tools
dnf install -y --setopt=install_weak_deps=False \
  fuse \
  fuse-libs \
  fuse-sshfs \
  fuse-overlayfs 

# Firmwares
dnf install -y --setopt=install_weak_deps=False \
  alsa-firmware \
  linux-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  iwlwifi-mld-firmware \
  iwlwifi-mvm-firmware

# Udev Rules (Hardware / Peripherals)
dnf install -y --setopt=install_weak_deps=False \
  solaar-udev \
  xr-hardware \
  udev-hid-bpf \
  trezor-common \
  liquidctl-udev \
  oversteer-udev \
  mooltipass-udev \
  openrgb-udev-rules \
  ublue-os-udev-rules \
  udev-hid-bpf-stable \
  3dprinter-udev-rules \
  power-profiles-daemon \
  unifying-receiver-udev

# System Tools (Hardware / Peripherals)
dnf install -y --setopt=install_weak_deps=False \
  bolt \
  upower \
  fprintd \
  usbmuxd \
  pciutils \
  usbutils \
  libinput \
  liquidctl \
  lm_sensors \
  fprintd-pam \
  libinput-utils \
  libratbag-ratbagd

# Audio (ALSA / PipeWire)
dnf install -y --setopt=install_weak_deps=False \
  alsa-ucm \
  pipewire \
  alsa-utils \
  wireplumber \
  pipewire-alsa \
  pipewire-libs \
  pipewire-v4l2 \
  pipewire-utils \
  pipewire-gstreamer \
  pipewire-libs-extra \
  pipewire-pulseaudio \
  pipewire-config-raop \
  pipewire-plugin-libcamera \
  pipewire-jack-audio-connection-kit \
  pipewire-jack-audio-connection-kit-libs

# Camera / Video Capture
dnf install -y --setopt=install_weak_deps=False \
  gphoto2 \
  libcamera \
  v4l-utils \
  libgphoto2 \
  libcamera-ipa \
  libcamera-v4l2 \
  libcamera-gstreamer

# Image Codecs
dnf install -y --setopt=install_weak_deps=False \
  libjxl \
  libavif \
  libheif \
  libwebp

# FFmpeg / Media Encoding
dnf install -y --setopt=install_weak_deps=False \
  exiv2 \
  ffmpeg \
  libldac \
  libfdk-aac \
  ffmpeg-libs \
  libfreeaptx \
  glycin-loaders \
  ffmpegthumbnailer

# CD/BlueRay Media Drivers
dnf install -y --setopt=install_weak_deps=False \
  mkisofs \
  cdda2wav \
  cdrecord \
  schily-libs

# Graphics / GPU Drivers
dnf install -y --setopt=install_weak_deps=False \
  vdpauinfo \
  mesa-libGL \
  mesa-libEGL \
  mesa-libgbm \
  libva-utils \
  intel-gmmlib \
  vulkan-tools \
  mesa-filesystem \
  mesa-va-drivers \
  intel-vpl-gpu-rt \
  mesa-dri-drivers \
  mesa-vulkan-drivers \
  libva-intel-media-driver

# GStreamer Plugins
dnf install -y --setopt=install_weak_deps=False \
  gstreamer1-plugins-bad \
  gstreamer1-plugin-libav \
  gstreamer1-plugins-ugly \
  gstreamer1-plugins-good \
  gstreamer1-plugins-good-extras

# Core System / Init
dnf install -y --setopt=install_weak_deps=False \
  nix \
  fwupd \
  flatpak \
  freerdp \
  plymouth \
  i2c-tools \
  nix-daemon \
  uresourced \
  dbus-daemon \
  shadow-utils \
  inotify-tools \
  unbound-anchor \
  usb_modeswitch \
  zram-generator \
  kernel-tools-libs \
  kernel-modules-extra \
  systemd-oomd-defaults \
  plymouth-plugin-two-step

# Shell / Terminal
dnf install -y --setopt=install_weak_deps=False \
  zsh \
  bash \
  bash-completion \
  zsh-autosuggestions \
  zsh-syntax-highlighting

# Performance / Gaming
dnf install -y --setopt=install_weak_deps=False \
  mangohud \
  gamemode \
  scx-tools \
  scx-scheds \
  tpm2-tools

# SSH Tools
dnf install -y --setopt=install_weak_deps=False \
  openssh \
  openssh-server \
  openssh-clients \
  openssh-askpass \
  openssh-keysign \

# CLI Tools
dnf install -y --setopt=install_weak_deps=False \
  bat \
  eza \
  fzf \
  git \
  gum \
  btop \
  curl \
  zrun \
  neovim \
  zfetch \
  zoxide \
  fd-find \
  git-lfs \
  ripgrep \
  starship \
  topgrade \
  git-annex \
  git-delta \
  trash-cli \
  eza-zsh-completion

# Container Tools
dnf install -y --setopt=install_weak_deps=False \
  lxc \
  crun \
  lxcfs \
  podman \
  buildah \
  lxc-libs \
  lxc-templates \
  otter \
  incus \
  waydroid \
  incus-tools \
  incus-client \
  incus-selinux

# Networking / Connectivity
dnf install -y --setopt=install_weak_deps=False \
  iwd \
  bluez \
  openvpn \
  firewalld \
  bluez-libs \
  cifs-utils \
  avahi-tools \
  openconnect \
  iptables-nft \
  ModemManager \
  wpa_supplicant \
  wireguard-tools

# Network Manager
dnf install -y --setopt=install_weak_deps=False \
  NetworkManager \
  NetworkManager-wifi \
  NetworkManager-wwan \
  NetworkManager-openvpn \
  NetworkManager-bluetooth \
  NetworkManager-openconnect \
  mobile-broadband-provider-info \
  NetworkManager-config-connectivity-fedora

# Printing / Scanning
dnf install -y --setopt=install_weak_deps=False \
  cups \
  hplip \
  ipp-usb \
  nss-mdns \
  cups-client \
  foomatic-db \
  cups-browsed \
  cups-filters \
  samba-client \
  sane-backends \
  cups-pk-helper \
  gutenprint-cups \
  cups-filters-driverless