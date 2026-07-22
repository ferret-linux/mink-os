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
  libvirt-client-qemu
  libvirt-daemon-common
  libvirt-daemon-driver-lxc
  libvirt-daemon-driver-qemu
  libvirt-daemon-driver-secret
  libvirt-daemon-plugin-sanlock
  libvirt-daemon-config-network
  libvirt-daemon-driver-network
  libvirt-daemon-driver-nodedev
  libvirt-daemon-config-nwfilter
  libvirt-daemon-driver-nwfilter
  libvirt-daemon-driver-interface
  libvirt-daemon-driver-storage-rbd
  libvirt-daemon-driver-storage-zfs
  libvirt-daemon-driver-storage-core
  libvirt-daemon-driver-storage-disk
  libvirt-daemon-driver-storage-mpath
  libvirt-daemon-driver-storage-iscsi
  libvirt-daemon-driver-storage-gluster
  libvirt-daemon-driver-storage-logical
  libvirt-daemon-driver-storage-iscsi-direct
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
  usbip
  swtpm
  libnbd
  nbdkit
  mdevctl
  sanlock
  dnsmasq
  numactl
  pciutils
  usbredir
  driverctl
  edk2-ovmf
  sg3_utils
  nfs-utils
  libguestfs
  swtpm-tools
  bridge-utils
  iptables-nft
  spice-server
  guestfs-tools
  python3-libvirt
  iscsi-initiator-utils
)

VIRT_MANAGEMENT=(
  virt-top
  virtiofsd
  virt-viewer
  virt-install
  virt-manager
  virtnbdbackup
  virt-bootstrap
  virt-lightning
)

# Kernel module for GPU-passthrough / single-GPU VM setups (Looking Glass)
# (needs KERNEL_VERSION expansion, so built dynamically)
VIRT_KERNEL_MODULES=(
  "kmod-kvmfr-${KERNEL_VERSION}"
)

VIRT_KMOD_PACKAGES=(
  kvmfr-kmod-common
)

INCUS=(
  incus
  incus-ui
  incus-tools
  incus-client
  incus-selinux
)

HW_DIAGNOSTICS=(
  inxi
  nvme-cli
  dmidecode
  smartmontools
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
  "${VIRT_KERNEL_MODULES[@]}"
  "${VIRT_KMOD_PACKAGES[@]}"
  "${INCUS[@]}"
  "${HW_DIAGNOSTICS[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"

# Settings
systemctl enable incus-user.socket
systemctl enable incus.socket