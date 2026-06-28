#!/bin/bash

set -ouex pipefail

# Add Nvidia Drivers Repos
dnf config-manager setopt fedora-multimedia.enabled=0
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager setopt fedora-nvidia.enabled=1
dnf config-manager setopt fedora-nvidia.priority=90
dnf makecache --refresh

# Install Nvidia Kmods Drivers
dnf install --setopt=install_weak_deps=False -y nvidia-modprobe nvidia-driver-selinux \
    nvidia-kmod-common kmod-nvidia-"$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Install Nvidia Userspace Drivers
dnf install --setopt=install_weak_deps=False -y \
    libnvidia-fbc \
    nvidia-driver \
    nvidia-libXNVCtrl \
    libva-nvidia-driver \
    nvidia-persistenced \
    nvidia-driver-NvFBCOpenGL

# Install Nvidia X11 settings
dnf install --setopt=install_weak_deps=False -y \
    nvidia-xconfig

# Install Nvidia Cuda Toolkit
dnf install --setopt=install_weak_deps=False -y \
    cuda \
    cuda-libs \
    cuda-devel \
    nvidia-driver-cuda \
    nvidia-driver-cuda-libs

# Install Nvidia Container Toolkit
dnf install --setopt=install_weak_deps=False -y \
    nvidia-container-toolkit \
    nvidia-container-services \
    nvidia-container-toolkit-selinux

# Install Nvidia Tools/App
dnf install --setopt=install_weak_deps=False -y \
    prime-run \
    nvidia-settings

# Nvidia Services
systemctl enable nvidia-persistenced.service

# Fix Kmods Tree & loading
depmod -a "$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"
sed -i 's/omit_drivers/force_drivers/g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's/ nvidia / i915 amdgpu nvidia /g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Cleanup
dnf config-manager setopt fedora-nvidia.enabled=0
rm -f /etc/yum.repos.d/fedora-nvidia.repo
dnf config-manager setopt fedora-multimedia.enabled=1