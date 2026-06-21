#!/bin/bash
set -eoux pipefail

KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Install kernel modules
dnf install -y --setopt=install_weak_deps=False \
  kmod-wl-"${KERNEL_VERSION}" \
  kmod-zfs-"${KERNEL_VERSION}" \
  kmod-evdi-"${KERNEL_VERSION}" \
  kmod-xone-"${KERNEL_VERSION}" \
  kmod-sc0710-"${KERNEL_VERSION}" \
  kmod-xpadneo-"${KERNEL_VERSION}" \
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
  xpadneo-kmod-common \
  openrazer-kmod-common \
  hid-tmff2-akmod-modules \
  new-lg4ff-akmod-modules \
  v4l2loopback-akmod-modules \
  hid-fanatecff-akmod-modules

# Rebuild module dependencies
depmod -a "${KERNEL_VERSION}"