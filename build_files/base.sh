#!/bin/bash
set -eoux pipefail

# Base Linux packages
dnf install -y --setopt=install_weak_deps=False \
  alsa-ucm \
  alsa-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  iwlwifi-mvm-firmware \
  iwlwifi-mld-firmware \
  libcamera \
  libcamera-ipa \
  libcamera-v4l2 \
  libcamera-gstreamer \
  pipewire-plugin-libcamera \
  gphoto2 \
  libgphoto2 \
  pipewire-v4l2 \
  linux-firmware \
  kernel-tools-libs \
  kernel-modules-extra \
  i2c-tools \
  uresourced \
  dbus-daemon \
  shadow-utils \
  vulkan-tools \
  inotify-tools \
  unbound-anchor \
  zram-generator \
  usb_modeswitch \
  systemd-oomd-defaults \
  flatpak \
  nix \
  make \
  patch \
  glibc \
  sqlite \
  busybox \
  nix-daemon \
  falcond \
  mangohud \
  scx-tools \
  scx-scheds \
  tpm2-tools \
  fuse \
  freerdp \
  fuse-libs \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  plymouth \
  plymouth-plugin-two-step \
  pciutils \
  usbutils \
  v4l-utils \
  vdpauinfo \
  alsa-utils \
  libva-utils \
  pipewire-utils \
  libinput-utils

# Image Codecs
dnf install -y --setopt=install_weak_deps=False \
  libjxl \
  libheif \
  libwebp \
  libavif

# FFmpeg
dnf install -y --setopt=install_weak_deps=False \
  exiv2 \
  ffmpeg \
  libldac \
  libfdk-aac \
  ffmpeg-libs \
  libfreeaptx \
  ffmpegthumbnailer \
  glycin-loaders

# Mesa Drivers
dnf install -y --setopt=install_weak_deps=False \
  mesa-libGL \
  mesa-libgbm \
  mesa-libEGL \
  mesa-filesystem \
  mesa-dri-drivers

# Intel Media Drivers
dnf install -y --setopt=install_weak_deps=False \
  intel-gmmlib \
  intel-vpl-gpu-rt \
  libva-intel-media-driver

# AMD Media Drivers
dnf install -y --setopt=install_weak_deps=False \
  mesa-va-drivers \
  mesa-vulkan-drivers

# Gstreamer Plugins
dnf install -y --setopt=install_weak_deps=False \
  gstreamer1-plugins-bad \
  gstreamer1-plugin-libav \
  gstreamer1-plugins-ugly \
  gstreamer1-plugins-good \
  gstreamer1-plugins-good-extras

# Pipewire Stack
dnf install -y --setopt=install_weak_deps=False \
  pipewire \
  wireplumber \
  pipewire-alsa \
  pipewire-libs \
  pipewire-gstreamer \
  pipewire-libs-extra \
  pipewire-pulseaudio \
  pipewire-config-raop \
  pipewire-jack-audio-connection-kit \
  pipewire-jack-audio-connection-kit-libs

# Devtools
dnf install -y --setopt=install_weak_deps=False \
  bat \
  eza \
  fzf \
  btop \
  zoxide \
  fd-find \
  ripgrep \
  starship \
  trash-cli \
  eza-zsh-completion \
  gcc \
  curl \
  zstd \
  gcc-c++ \
  neovim \
  zrun \
  zfetch \
  topgrade \
  git \
  git-lfs \
  git-annex \
  git-delta \
  crun \
  podman \
  buildah \
  lxc \
  lxc-libs \
  lxc-templates \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Hardware Stuff
dnf install -y --setopt=install_weak_deps=False \
  bolt \
  upower \
  power-profiles-daemon \
  fprintd \
  fprintd-pam \
  liquidctl \
  libratbag-ratbagd \
  libinput \
  usbmuxd \
  lm_sensors \
  solaar-udev \
  xr-hardware \
  trezor-common \
  oversteer-udev \
  liquidctl-udev \
  udev-hid-bpf \
  openrgb-udev-rules \
  3dprinter-udev-rules \
  ublue-os-udev-rules \
  unifying-receiver-udev \
  udev-hid-bpf-stable \
  mooltipass-udev

# Connectivity
dnf install -y --setopt=install_weak_deps=False \
  bluez \
  bluez-libs \
  firewalld \
  openvpn \
  openconnect \
  wireguard-tools \
  iwd \
  cifs-utils \
  fuse-sshfs \
  avahi-tools \
  ModemManager \
  iptables-nft \
  wpa_supplicant \
  mobile-broadband-provider-info \
  NetworkManager \
  NetworkManager-wifi \
  NetworkManager-wwan \
  NetworkManager-openvpn \
  NetworkManager-bluetooth \
  NetworkManager-openconnect \
  NetworkManager-config-connectivity-fedora

# Printing
dnf install -y --setopt=install_weak_deps=False \
  hplip \
  cups \
  cups-client \
  cups-filters \
  cups-browsed \
  cups-pk-helper \
  cups-filters-driverless \
  ipp-usb \
  nss-mdns \
  foomatic-db \
  gutenprint-cups \
  samba-client \
  sane-backends