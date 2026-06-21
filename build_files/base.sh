#!/bin/bash
set -eoux pipefail

# Firmware
dnf install -y --setopt=install_weak_deps=False \
  alsa-firmware \
  linux-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  iwlwifi-mld-firmware \
  iwlwifi-mvm-firmware

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

# Graphics / GPU Drivers
dnf install -y --setopt=install_weak_deps=False \
  vdpauinfo \
  mesa-libGL \
  libva-utils \
  mesa-libEGL \
  mesa-libgbm \
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
  gstreamer1-plugins-good \
  gstreamer1-plugins-ugly \
  gstreamer1-plugins-good-extras

# Core System / Init
dnf install -y --setopt=install_weak_deps=False \
  nix \
  fuse \
  make \
  glibc \
  patch \
  sqlite \
  busybox \
  flatpak \
  freerdp \
  fuse-libs \
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
  systemd-oomd-defaults

# Shell / Terminal
dnf install -y --setopt=install_weak_deps=False \
  zsh \
  pciutils \
  plymouth \
  usbutils \
  libinput-utils \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  plymouth-plugin-two-step

# Performance / Gaming
dnf install -y --setopt=install_weak_deps=False \
  mangohud \
  scx-tools \
  scx-scheds \
  tpm2-tools

# Dev Tools / CLI
dnf install -y --setopt=install_weak_deps=False \
  bat \
  eza \
  fzf \
  gcc \
  git \
  lxc \
  gum \
  btop \
  crun \
  curl \
  zrun \
  zstd \
  otter \
  incus \
  neovim \
  podman \
  zfetch \
  zoxide \
  buildah \
  fd-find \
  gcc-c++ \
  git-lfs \
  ripgrep \
  lxc-libs \
  starship \
  topgrade \
  git-annex \
  git-delta \
  trash-cli \
  lxc-templates \
  eza-zsh-completion

# Hardware / Peripherals
dnf install -y --setopt=install_weak_deps=False \
  bolt \
  upower \
  fprintd \
  usbmuxd \
  libinput \
  liquidctl \
  lm_sensors \
  fprintd-pam \
  solaar-udev \
  xr-hardware \
  udev-hid-bpf \
  trezor-common \
  liquidctl-udev \
  oversteer-udev \
  mooltipass-udev \
  libratbag-ratbagd \
  openrgb-udev-rules \
  ublue-os-udev-rules \
  udev-hid-bpf-stable \
  3dprinter-udev-rules \
  power-profiles-daemon \
  unifying-receiver-udev

# Networking / Connectivity
dnf install -y --setopt=install_weak_deps=False \
  iwd \
  bluez \
  openvpn \
  firewalld \
  bluez-libs \
  cifs-utils \
  fuse-sshfs \
  avahi-tools \
  openconnect \
  iptables-nft \
  ModemManager \
  NetworkManager \
  wpa_supplicant \
  wireguard-tools \
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