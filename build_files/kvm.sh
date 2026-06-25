#!/bin/bash
set -eoux pipefail

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