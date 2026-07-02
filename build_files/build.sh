#!/bin/bash
set -eoux pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Build Tools
dnf install -y --setopt=install_weak_deps=False \
  gcc \
  file \
  zstd \
  make \
  just \
  glibc \
  patch \
  rsync \
  sqlite \
  gcc-c++ \
  doxygen \
  busybox \
  diffstat \
  systemtap \
  procps-ng \
  patchutils \
  subversion

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

# LXC/Incus
dnf install -y --setopt=install_weak_deps=False \
  lxc \
  lxcfs \
  incus \
  lxc-libs \
  incus-tools \
  incus-client \
  incus-selinux \
  lxc-templates

# Podman Env
dnf install -y --setopt=install_weak_deps=False \
  crun \
  bootc \
  podman \
  skopeo \
  buildah \

# Docker CE
dnf install -y --setopt=install_weak_deps=False \
  docker-ce \
  lazydocker \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Container Tools
dnf install -y --setopt=install_weak_deps=False \
  otter \
  waydroid \
  distrobox

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

# Install kernel modules
dnf install -y --setopt=install_weak_deps=False \
  kmod-wl-"${KERNEL_VERSION}" \
  kmod-zfs-"${KERNEL_VERSION}" \
  kmod-evdi-"${KERNEL_VERSION}" \
  kmod-xone-"${KERNEL_VERSION}" \
  kmod-kvmfr-"${KERNEL_VERSION}" \
  kmod-sc0710-"${KERNEL_VERSION}" \
  kmod-xpadneo-"${KERNEL_VERSION}" \
  kmod-zenergy-"${KERNEL_VERSION}" \
  kmod-hid-tmff2-"${KERNEL_VERSION}" \
  kmod-new-lg4ff-"${KERNEL_VERSION}" \
  kmod-openrazer-"${KERNEL_VERSION}" \
  kmod-v4l2loopback-"${KERNEL_VERSION}" \
  kmod-hid-fanatecff-"${KERNEL_VERSION}" \
  kernel-devel-matched-"${KERNEL_VERSION}"

# Install kmod packages
dnf install -y --setopt=install_weak_deps=False \
  zfs \
  sc0710 \
  libevdi \
  libzfs7 \
  zenergy \
  hid-tmff2 \
  libuutil3 \
  libzpool7 \
  new-lg4ff \
  libnvpair3 \
  zfs-dracut \
  broadcom-wl \
  displaylink \
  v4l2loopback \
  hid-fanatecff \
  python3-pyzfs \
  xone-kmod-common \
  kvmfr-kmod-common \
  xpadneo-kmod-common \
  openrazer-kmod-common \
  zenergy-akmod-modules \
  hid-tmff2-akmod-modules \
  new-lg4ff-akmod-modules \
  v4l2loopback-akmod-modules \
  hid-fanatecff-akmod-modules

# Rebuild module dependencies
depmod -a "${KERNEL_VERSION}"

# KVM Requirements
dnf install -y --setopt=install_weak_deps=False \
  lshw \
  tuna \
  passt \
  swtpm \
  libnbd \
  nbdkit \
  numactl \
  dnsmasq \
  pciutils \
  usbredir \
  driverctl \
  edk2-ovmf \
  sg3_utils \
  libguestfs \
  swtpm-tools \
  spice-server \
  bridge-utils \
  iptables-nft \
  guestfs-tools \
  python3-libvirt \

# QEMU-KVM
dnf install -y --setopt=install_weak_deps=False \
  qemu-img \
  qemu-kvm \
  qemu-tools \
  qemu-ui-gtk \
  qemu-ui-sdl \
  qemu-kvm-core \
  qemu-block-nfs \
  qemu-block-rbd \
  qemu-block-ssh \
  qemu-pr-helper \
  qemu-ui-opengl \
  qemu-audio-alsa \
  qemu-block-curl \
  qemu-char-spice \
  qemu-audio-spice \
  qemu-ui-spice-app \
  qemu-ui-spice-core \
  qemu-audio-pipewire \
  qemu-device-usb-host \
  qemu-device-display-qxl \
  qemu-device-usb-redirect \
  qemu-device-usb-smartcard \
  qemu-device-display-virtio-gpu \
  qemu-device-display-virtio-vga \
  qemu-device-display-virtio-gpu-gl \
  qemu-device-display-virtio-vga-gl \
  qemu-device-display-virtio-gpu-pci \
  qemu-device-display-virtio-gpu-pci-gl \
  qemu-device-display-virtio-gpu-rutabaga

# libvirt
dnf install -y --setopt=install_weak_deps=False \
  libvirt \
  libvirt-nss \
  libvirt-client \
  libvirt-daemon-kvm \
  libvirt-daemon-driver-qemu \
  libvirt-daemon-config-network \
  libvirt-daemon-driver-nodedev \
  libvirt-daemon-config-nwfilter \
  libvirt-daemon-driver-storage-core

# Virt Extras
dnf install -y --setopt=install_weak_deps=False \
  virt-top \
  virtiofsd \
  virt-backup \
  virt-install \
  virt-manager \
  virtnbdbackup \
  virt-lightning \
  virt-bootstrap

# Nerd Fonts
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

# Fonts & Language Packs
dnf install -y --setopt=install_weak_deps=False \
  harfbuzz \
  stix-fonts \
  langpacks-en \
  unicode-emoji \
  cracklib-dicts \
  langpacks-core-en \
  langpacks-fonts-en \
  glibc-all-langpacks \
  glibc-locale-source \
  liberation-fonts-all \
  google-noto-emoji-fonts \
  google-noto-sans-vf-fonts \
  google-noto-serif-vf-fonts \
  google-noto-sans-cjk-vf-fonts \
  google-noto-color-emoji-fonts \
  google-noto-sans-thai-vf-fonts \
  google-noto-sans-arabic-vf-fonts \
  google-noto-sans-hebrew-vf-fonts \
  google-noto-sans-devanagari-vf-fonts
