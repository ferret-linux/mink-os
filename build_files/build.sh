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

FUSE_TOOLS=(
  fuse
  ifuse
  fuse3
  bindfs
  jmtpfs
  nbdfuse
  chunkfs
  gphotofs
  fuse-zip
  fuse-afp
  apfs-fuse
  s3fs-fuse
  fuse-libs
  fuse-encfs
  erofs-fuse
  fuse3-libs
  fuse-sshfs
  squashfuse
  fuse-common
  archivemount
  fuse-bcachefs
  fuse-overlayfs
  fuse-dislocker
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
  iwlwifi-mld-firmware
  iwlwifi-mvm-firmware
  iwlwifi-dvm-firmware
  cirrus-audio-firmware
)

UDEV_RULES=(
  solaar-udev
  xr-hardware
  udev-hid-bpf
  trezor-common
  liquidctl-udev
  oversteer-udev
  mooltipass-udev
  openrgb-udev-rules
  ublue-os-udev-rules
  udev-hid-bpf-stable
  3dprinter-udev-rules
  python-btchip-common
  unifying-receiver-udev
  system-config-printer-udev
)

SYSTEM_TOOLS_HW=(
  inxi
  bolt
  upower
  ddcutil
  fprintd
  usbmuxd
  libinput
  pciutils
  usbutils
  nvme-cli
  dmidecode
  liquidctl
  tpm2-tools
  lm_sensors
  fprintd-pam
  smartmontools
  brightnessctl
  libinput-utils
  libratbag-ratbagd
  power-profiles-daemon
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
  zenergy-akmod-modules
  hid-tmff2-akmod-modules
  new-lg4ff-akmod-modules
  v4l2loopback-akmod-modules
  hid-fanatecff-akmod-modules
)

AUDIO=(
  wiremix
  alsa-ucm
  pipewire
  alsa-utils
  alsa-tools
  wireplumber
  pipewire-alsa
  pipewire-libs
  pipewire-v4l2
  pipewire-utils
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

CD_BLURAY=(
  mkisofs
  cdda2wav
  cdrecord
  libbluray
  schily-libs
  dvd+rw-tools
  libbluray-utils
)

GRAPHICS_GPU=(
  vdpauinfo
  mesa-libGL
  libva-utils
  mesa-libEGL
  mesa-libgbm
  intel-gmmlib
  vulkan-tools
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
  gstreamer1-plugins-bad-opencv
  gstreamer1-plugins-base-tools
  gstreamer1-plugins-good-extras
  gstreamer1-plugins-bad-fluidsynth
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
  jq
  yq
  bat
  eza
  fzf
  gum
  dust
  btop
  curl
  zrun
  tmux
  ncdu
  procs
  direnv
  neovim
  zfetch
  zoxide
  fd-find
  ripgrep
  starship
  topgrade
  trash-cli
  hyperfine
)

GIT_TOOLS=(
  gh
  git
  gitui
  git-lfs
  gitleaks
  git-annex
  git-delta
  git-crypt
  difftastic
  git-cinnabar
  git-filter-repo
  git-credential-libsecret
)

PERF_GAMING=(
  gamemode
  mangohud
  vkBasalt
  gamescope
  scx-tools
  scx-scheds
)

SSH_TOOLS=(
  mosh
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
  skopeo
  buildah
)

NETWORKING=(
  iwd
  bluez
  avahi
  openvpn
  usbguard
  tailscale
  firewalld
  bluez-libs
  cifs-utils
  avahi-tools
  openconnect
  iptables-nft
  ModemManager
  wpa_supplicant
  wireguard-tools
)

NETWORK_MANAGER=(
  NetworkManager
  NetworkManager-wifi
  NetworkManager-wwan
  NetworkManager-openvpn
  NetworkManager-bluetooth
  NetworkManager-openconnect
  mobile-broadband-provider-info
  NetworkManager-config-connectivity-fedora
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

FONTS_LANGPACKS=(
  harfbuzz
  fontconfig
  stix-fonts
  langpacks-en
  unicode-emoji
  cracklib-dicts
  dejavu-sans-fonts
  dejavu-serif-fonts
  langpacks-fonts-en
  glibc-all-langpacks
  glibc-locale-source
  liberation-fonts-all
  dejavu-sans-mono-fonts
  google-noto-emoji-fonts
  google-noto-sans-vf-fonts
  google-noto-serif-vf-fonts
  google-noto-sans-lao-vf-fonts
  google-noto-color-emoji-fonts
  google-noto-sans-cjk-vf-fonts
  google-noto-sans-thai-vf-fonts
  google-noto-sans-mono-vf-fonts
  google-noto-serif-cjk-vf-fonts
  google-noto-sans-khmer-vf-fonts
  google-noto-sans-tamil-vf-fonts
  google-noto-sans-arabic-vf-fonts
  google-noto-sans-hebrew-vf-fonts
  google-noto-sans-symbols-2-fonts
  google-noto-sans-sinhala-vf-fonts
  google-noto-sans-symbols-vf-fonts
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