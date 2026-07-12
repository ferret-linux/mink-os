#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

FUSE_TOOLS=(
  fuse
  fuse3
  fuse-libs
  fuse3-libs
  fuse-common
  fuse-overlayfs
)

FIRMWARES=(
  iwlwifi-mld-firmware
  iwlwifi-mvm-firmware
  iwlwifi-dvm-firmware
)

UDEV_RULES=(
  udev-hid-bpf
  udev-hid-bpf-stable
)

SYSTEM_TOOLS_HW=(
  libinput
  pciutils
  usbutils
  tpm2-tools
  lm_sensors
  libinput-utils
)

AUDIO=(
  alsa-ucm
  pipewire
  alsa-utils
  wireplumber
  pipewire-alsa
  pipewire-libs
  pipewire-v4l2
  alsa-ucm-utils
  pipewire-gstreamer
  pipewire-libs-extra
  pipewire-pulseaudio
  alsa-topology-utils
  pipewire-config-raop
  pipewire-config-rates
  pipewire-plugin-libcamera
  pipewire-jack-audio-connection-kit
  pipewire-jack-audio-connection-kit-libs
)

CAMERA_VIDEO=(
  gphoto2
  libcamera
  v4l-utils
  libgphoto2
  libcamera-ipa
  libcamera-v4l2
  libcamera-gstreamer
)

IMAGE_CODECS=(
  LibRaw
  giflib
  libjxl
  libtiff
  libspng
  libavif
  libheif
  libwebp
  openexr
  librsvg2
  libjpeg-turbo
)

FFMPEG_MEDIA=(
  exiv2
  ffmpeg
  libldac
  libfdk-aac
  ffmpeg-libs
  libfreeaptx
  glycin-loaders
  ffmpegthumbnailer
)

GRAPHICS_GPU=(
  mesa-libGL
  mesa-libEGL
  mesa-libgbm
  intel-gmmlib
  mesa-libOpenCL
  intel-mediasdk
  mesa-libTeflon
  mesa-filesystem
  mesa-va-drivers
  intel-vpl-gpu-rt
  mesa-dri-drivers
  intel-vaapi-driver
  mesa-vulkan-drivers
  libva-intel-media-driver
)

GSTREAMER_PLUGINS=(
  gstreamer1
  gstreamer1-vaapi
  gstreamer1-plugins-bad
  gstreamer1-plugins-base
  gstreamer1-plugin-libav
  gstreamer1-plugins-good
  gstreamer1-plugins-ugly
  gstreamer1-plugins-base-tools
  gstreamer1-plugins-good-extras
)

CORE_SYSTEM=(
  otter
  audit
  fwupd
  polkit
  udisks2
  flatpak
  freerdp
  plymouth
  i2c-tools
  uresourced
  dbus-daemon
  shadow-utils
  inotify-tools
  unbound-anchor
  usb_modeswitch
  zram-generator
  kernel-tools-libs
  kernel-modules-extra
  systemd-oomd-defaults
  plymouth-plugin-two-step
)

NIX=(
  nix
  patch
  nix-doc
  busybox
  binutils
  nix-libs
  nix-legacy
  nix-system
  nix-daemon
  nix-filesystem
)

SHELL_TERMINAL=(
  zsh
  bash
  bash-completion
  zsh-autosuggestions
  zsh-syntax-highlighting
)

CLI_TOOLS=(
  bat
  eza
  fzf
  gum
  dust
  btop
  curl
  zrun
  procs
  neovim
  zfetch
  zoxide
  fd-find
  ripgrep
  starship
  topgrade
  trash-cli
)

GIT_TOOLS=(
  git
  git-lfs
  git-credential-libsecret
)

SSH_TOOLS=(
  openssh
  pcsc-lite
  openssh-server
  openssh-askpass
  openssh-clients
  openssh-keysign
)

PODMAN_ENV=(
  crun
  bootc
  podman
)

NETWORKING=(
  iwd
  bluez
  avahi
  firewalld
  bluez-libs
  cifs-utils
  avahi-tools
  iptables-nft
  ModemManager
  wpa_supplicant
)

NETWORK_MANAGER=(
  NetworkManager
  NetworkManager-wifi
  NetworkManager-wwan
  NetworkManager-bluetooth
  mobile-broadband-provider-info
  NetworkManager-config-connectivity-fedora
)

FONTS_LANGPACKS=(
  harfbuzz
  fontconfig
  stix-fonts
  langpacks-en
  unicode-emoji
  cracklib-dicts
  hack-nerd-fonts
  langpacks-fonts-en
  glibc-all-langpacks
  glibc-locale-source
  liberation-fonts-all
  dejavu-sans-mono-fonts
  google-noto-emoji-fonts
  google-noto-sans-vf-fonts
  google-noto-serif-vf-fonts
  google-noto-color-emoji-fonts
  google-noto-sans-cjk-vf-fonts
  google-noto-sans-mono-vf-fonts
  google-noto-serif-cjk-vf-fonts
  nerdfontssymbolsonly-nerd-fonts
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
  "${FIRMWARES[@]}"
  "${SSH_TOOLS[@]}"
  "${FUSE_TOOLS[@]}"
  "${PODMAN_ENV[@]}"
  "${NETWORKING[@]}"
  "${UDEV_RULES[@]}"
  "${CORE_SYSTEM[@]}"
  "${GRAPHICS_GPU[@]}"
  "${CAMERA_VIDEO[@]}"
  "${IMAGE_CODECS[@]}"
  "${FFMPEG_MEDIA[@]}"
  "${SHELL_TERMINAL[@]}"
  "${NETWORK_MANAGER[@]}"
  "${SYSTEM_TOOLS_HW[@]}"
  "${FONTS_LANGPACKS[@]}"
  "${GSTREAMER_PLUGINS[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"