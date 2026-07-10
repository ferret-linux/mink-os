#!/bin/bash
set -euxo pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

LIBVIRT=(
  libvirt
  libvirt-nss
  libvirt-client
  libvirt-daemon-kvm
  libvirt-daemon-lxc
  libvirt-daemon-common
  libvirt-daemon-driver-lxc
  libvirt-daemon-driver-qemu
  libvirt-daemon-driver-secret
  libvirt-daemon-config-network
  libvirt-daemon-driver-network
  libvirt-daemon-driver-nodedev
  libvirt-daemon-config-nwfilter
  libvirt-daemon-driver-nwfilter
  libvirt-daemon-driver-interface
  libvirt-daemon-driver-storage-zfs
  libvirt-daemon-driver-storage-core
  libvirt-daemon-driver-storage-disk
  libvirt-daemon-driver-storage-logical
)

QEMU=(
  qemu-img
  qemu-kvm
  qemu-rdp
  qemu-docs
  qemu-tools
  qemu-ui-gtk
  qemu-ui-sdl
  qemu-common
  qemu-ui-dbus
  qemu-ui-curses
  qemu-block-nfs
  qemu-block-rbd
  qemu-block-ssh
  qemu-pr-helper
  qemu-ui-opengl
  qemu-block-dmg
  qemu-audio-dbus
  qemu-audio-alsa
  qemu-block-curl
  qemu-char-spice
  qemu-block-iscsi
  qemu-audio-spice
  qemu-block-blkio
  qemu-sanity-check
  qemu-ui-spice-app
  qemu-block-gluster
  qemu-ui-spice-core
  qemu-audio-pipewire
  qemu-device-usb-host
  qemu-ui-egl-headless
  qemu-device-uefi-vars
  qemu-device-display-qxl
  qemu-device-usb-redirect
  qemu-device-usb-smartcard
  qemu-device-display-virtio-gpu
  qemu-device-display-virtio-vga
  qemu-device-display-virtio-gpu-gl
  qemu-device-display-virtio-vga-gl
  qemu-device-display-virtio-gpu-pci
  qemu-device-display-vhost-user-gpu
  qemu-device-display-virtio-gpu-pci-gl
  qemu-device-display-virtio-gpu-rutabaga
  qemu-device-display-virtio-vga-rutabaga
  qemu-device-display-virtio-gpu-pci-rutabaga
)

QEMU_EMULATION=(
  qemu-user
  qemu-system-arm
  qemu-system-ppc
  qemu-system-x86
  qemu-system-mips
  qemu-user-static
  qemu-user-binfmt
  qemu-system-riscv
  qemu-system-s390x
  qemu-system-aarch64
  qemu-user-static-arm
  qemu-user-static-ppc
  qemu-user-static-mips
  qemu-user-static-riscv
  qemu-user-static-s390x
  qemu-system-loongarch64
  qemu-user-static-aarch64
  qemu-user-static-loongarch64
)

VIRT_HOST_DEPS=(
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

VIRT_MANAGEMENT=(
  virt-top
  virtiofsd
  gnome-boxes
  virt-install
  virt-manager
  virtnbdbackup
  virt-bootstrap
  virt-lightning
)

DOCKER=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

PODMAN=(
  skopeo
  buildah
  podman-tui
  podman-machine
)

LXC_INCUS=(
  lxc
  criu
  lxcfs
  incus
  incus-ui
  lxc-libs
  incus-tools
  incus-client
  incus-selinux
  lxc-templates
)

COCKPIT=(
  cockpit-bridge
  cockpit-ostree
  cockpit-podman
  cockpit-system
  cockpit-selinux
  cockpit-storaged
  cockpit-machines
  cockpit-networkmanager
)

CLI_UTILS=(
  jq
  yq
  tmux
  ncdu
  direnv
  hyperfine
)

GIT_TOOLS=(
  gh
  gitui
  gitleaks
  git-annex
  git-delta
  git-crypt
  difftastic
  git-cinnabar
  git-filter-repo
)

MUSL_TOOLCHAIN=(
  musl-gcc
  musl-libc
  musl-devel
  musl-filesystem
  musl-libc-static
)

DEV_TOOLS=(
  pods
  code
  waydroid
  distrobox
  android-tools
)

HW_DIAGNOSTICS=(
  inxi
  nvme-cli
  dmidecode
  smartmontools
)

FUSE_TOOLS=(
  ifuse
  bindfs
  jmtpfs
  nbdfuse
  chunkfs
  gphotofs
  fuse-zip
  fuse-afp
  apfs-fuse
  s3fs-fuse
  fuse-encfs
  erofs-fuse
  fuse-sshfs
  squashfuse
  archivemount
  fuse-bcachefs
  fuse-dislocker
)

AUDIO=(
  alsa-tools
  pipewire-utils
)

GSTREAMER=(
  gstreamer1-plugins-bad-opencv
  gstreamer1-plugins-bad-fluidsynth
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${LIBVIRT[@]}"
  "${QEMU[@]}"
  "${QEMU_EMULATION[@]}"
  "${VIRT_HOST_DEPS[@]}"
  "${VIRT_MANAGEMENT[@]}"
  "${DOCKER[@]}"
  "${PODMAN[@]}"
  "${LXC_INCUS[@]}"
  "${COCKPIT[@]}"
  "${CLI_UTILS[@]}"
  "${GIT_TOOLS[@]}"
  "${MUSL_TOOLCHAIN[@]}"
  "${DEV_TOOLS[@]}"
  "${HW_DIAGNOSTICS[@]}"
  "${FUSE_TOOLS[@]}"
  "${AUDIO[@]}"
  "${GSTREAMER[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"

# Settings
systemctl enable containerd.service
systemctl enable incus-user.socket
systemctl enable docker.service
systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable incus.socket