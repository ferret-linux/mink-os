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
  file
  just
  make
  zstd
  glibc
  patch
  rsync
  sqlite
  busybox
  doxygen
  gcc-c++
  diffstat
  procps-ng
  systemtap
  patchutils
  subversion
)

FUSE_TOOLS=(
  fuse
  fuse-libs
  fuse-sshfs
  fuse-overlayfs
)

FIRMWARES=(
  alsa-firmware
  linux-firmware
  alsa-sof-firmware
  alsa-tools-firmware
  iwlwifi-mld-firmware
  iwlwifi-mvm-firmware
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
  power-profiles-daemon
  unifying-receiver-udev
)

SYSTEM_TOOLS_HW=(
  bolt
  upower
  fprintd
  usbmuxd
  libinput
  pciutils
  usbutils
  liquidctl
  tpm2-tools
  lm_sensors
  fprintd-pam
  libinput-utils
  libratbag-ratbagd
)

# Kernel modules (need KERNEL_VERSION expansion, so built dynamically)
KERNEL_MODULES=(
  "kmod-wl-${KERNEL_VERSION}"
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
  broadcom-wl
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
  alsa-ucm
  pipewire
  alsa-utils
  wireplumber
  pipewire-alsa
  pipewire-libs
  pipewire-v4l2
  pipewire-utils
  pipewire-gstreamer
  pipewire-libs-extra
  pipewire-pulseaudio
  pipewire-config-raop
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
  libjxl
  libavif
  libheif
  libwebp
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
  schily-libs
)

GUI_APPS=(
  pods
  code
  resources
  helium-drm
  pika-backup
  gnome-boxes
  gnome-firmware
)

GRAPHICS_GPU=(
  vdpauinfo
  mesa-libGL
  libva-utils
  mesa-libEGL
  mesa-libgbm
  intel-gmmlib
  vulkan-tools
  mesa-filesystem
  mesa-va-drivers
  intel-vpl-gpu-rt
  mesa-dri-drivers
  mesa-vulkan-drivers
  libva-intel-media-driver
)

GSTREAMER_PLUGINS=(
  gstreamer1-plugins-bad
  gstreamer1-plugin-libav
  gstreamer1-plugins-good
  gstreamer1-plugins-ugly
  gstreamer1-plugins-good-extras
)

CORE_SYSTEM=(
  nix
  fwupd
  flatpak
  freerdp
  plymouth
  i2c-tools
  nix-daemon
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
  git
  gum
  btop
  curl
  zrun
  neovim
  zfetch
  zoxide
  fd-find
  git-lfs
  ripgrep
  starship
  topgrade
  git-annex
  git-delta
  trash-cli
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
  openssh
  openssh-server
  openssh-askpass
  openssh-clients
  openssh-keysign
)

LXC_INCUS=(
  lxc
  incus
  lxcfs
  lxc-libs
  incus-tools
  incus-client
  incus-selinux
  lxc-templates
)

PODMAN_ENV=(
  crun
  bootc
  podman
  skopeo
  buildah
)

DOCKER_CE=(
  docker-ce
  containerd.io
  docker-ce-cli
  docker-buildx-plugin
  docker-compose-plugin
)

CONTAINER_TOOLS=(
  otter
  waydroid
  distrobox
)

NETWORKING=(
  iwd
  bluez
  openvpn
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
  sane-backends
  cups-pk-helper
  gutenprint-cups
  cups-filters-driverless
)

KVM_REQUIREMENTS=(
  lshw
  tuna
  passt
  swtpm
  libnbd
  nbdkit
  dnsmasq
  numactl
  pciutils
  usbredir
  driverctl
  edk2-ovmf
  sg3_utils
  libguestfs
  swtpm-tools
  bridge-utils
  iptables-nft
  spice-server
  guestfs-tools
  python3-libvirt
)

QEMU_KVM=(
  qemu-img
  qemu-kvm
  qemu-tools
  qemu-ui-gtk
  qemu-ui-sdl
  qemu-kvm-core
  qemu-block-nfs
  qemu-block-rbd
  qemu-block-ssh
  qemu-pr-helper
  qemu-ui-opengl
  qemu-audio-alsa
  qemu-block-curl
  qemu-char-spice
  qemu-audio-spice
  qemu-ui-spice-app
  qemu-ui-spice-core
  qemu-audio-pipewire
  qemu-device-usb-host
  qemu-device-display-qxl
  qemu-device-usb-redirect
  qemu-device-usb-smartcard
  qemu-device-display-virtio-gpu
  qemu-device-display-virtio-vga
  qemu-device-display-virtio-gpu-gl
  qemu-device-display-virtio-vga-gl
  qemu-device-display-virtio-gpu-pci
  qemu-device-display-virtio-gpu-pci-gl
  qemu-device-display-virtio-gpu-rutabaga
)

LIBVIRT=(
  libvirt
  libvirt-nss
  libvirt-client
  libvirt-daemon-kvm
  libvirt-daemon-driver-qemu
  libvirt-daemon-config-network
  libvirt-daemon-driver-nodedev
  libvirt-daemon-config-nwfilter
  libvirt-daemon-driver-storage-core
)

VIRT_EXTRAS=(
  virt-top
  virtiofsd
  virt-backup
  virt-install
  virt-manager
  virtnbdbackup
  virt-bootstrap
  virt-lightning
)

FONTS_LANGPACKS=(
  harfbuzz
  stix-fonts
  langpacks-en
  unicode-emoji
  cracklib-dicts
  langpacks-core-en
  langpacks-fonts-en
  glibc-all-langpacks
  glibc-locale-source
  liberation-fonts-all
  google-noto-emoji-fonts
  google-noto-sans-vf-fonts
  google-noto-serif-vf-fonts
  google-noto-color-emoji-fonts
  google-noto-sans-cjk-vf-fonts
  google-noto-sans-thai-vf-fonts
  google-noto-sans-arabic-vf-fonts
  google-noto-sans-hebrew-vf-fonts
  google-noto-sans-devanagari-vf-fonts
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${BUILD_TOOLS[@]}"
  "${FUSE_TOOLS[@]}"
  "${FIRMWARES[@]}"
  "${UDEV_RULES[@]}"
  "${SYSTEM_TOOLS_HW[@]}"
  "${KERNEL_MODULES[@]}"
  "${KMOD_PACKAGES[@]}"
  "${AUDIO[@]}"
  "${CAMERA_VIDEO[@]}"
  "${IMAGE_CODECS[@]}"
  "${FFMPEG_MEDIA[@]}"
  "${CD_BLURAY[@]}"
  "${GRAPHICS_GPU[@]}"
  "${GSTREAMER_PLUGINS[@]}"
  "${CORE_SYSTEM[@]}"
  "${SHELL_TERMINAL[@]}"
  "${CLI_TOOLS[@]}"
  "${PERF_GAMING[@]}"
  "${SSH_TOOLS[@]}"
  "${LXC_INCUS[@]}"
  "${PODMAN_ENV[@]}"
  "${DOCKER_CE[@]}"
  "${CONTAINER_TOOLS[@]}"
  "${NETWORKING[@]}"
  "${NETWORK_MANAGER[@]}"
  "${PRINTING_SCANNING[@]}"
  "${KVM_REQUIREMENTS[@]}"
  "${QEMU_KVM[@]}"
  "${LIBVIRT[@]}"
  "${VIRT_EXTRAS[@]}"
  "${GUI_APPS[@]}"
  "${FONTS_LANGPACKS[@]}"
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