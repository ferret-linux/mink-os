#!/bin/bash

set -ouex pipefail

# Add Nvidia Drivers Repos
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager setopt fedora-nvidia.enabled=1
dnf config-manager setopt fedora-nvidia.priority=70
dnf makecache --refresh

# Install Nvidia Kmods Drivers
dnf install --setopt=install_weak_deps=False -y \
    nvidia-modprobe \
    nvidia-kmod-common \
    kmod-nvidia-"$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Install Nvidia Userspace Drivers
dnf install --setopt=install_weak_deps=False -y \
    libnvidia-fbc \
    nvidia-driver \
    nvidia-libXNVCtrl \
    nvidia-driver-cuda \
    libva-nvidia-driver \
    nvidia-persistenced \
    nvidia-driver-common \
    nvidia-driver-selinux \
    nvidia-driver-cuda-libs \
    nvidia-driver-NvFBCOpenGL

# Install Nvidia X11 settings
dnf install --setopt=install_weak_deps=False -y \
    nvidia-xconfig \
    xorg-x11-nvidia

# Install Nvidia Container Toolkit
dnf install --setopt=install_weak_deps=False -y \
    nvidia-container-toolkit \
    nvidia-container-services \
    nvidia-container-toolkit-selinux

# Install Nvidia Tools/App
dnf install --setopt=install_weak_deps=False -y \
    prime-run \
    nvidia-settings

# Install Nvidia Cuda Toolkit
dnf install --setopt=install_weak_deps=False -y \
    cuda \
    cuda-libs \
    cuda-devel

# Nvidia Services
systemctl enable nvidia-persistenced.service

# Fix Kmods Tree & loading
depmod -a "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"
sed -i 's/omit_drivers/force_drivers/g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's/ nvidia / i915 amdgpu nvidia /g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Cleanup
dnf config-manager setopt fedora-nvidia.enabled=0
rm -f /etc/yum.repos.d/fedora-nvidia.repo