#!/bin/bash

set -ouex pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Add Nvidia Drivers Repo
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager setopt fedora-nvidia.enabled=1
dnf config-manager setopt fedora-nvidia.priority=70
dnf makecache --refresh

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

NVIDIA_KMODS=(
  nvidia-modprobe
  nvidia-kmod-common
  "kmod-nvidia-${KERNEL_VERSION}"
)

NVIDIA_USERSPACE=(
  libnvidia-fbc
  nvidia-driver
  nvidia-libXNVCtrl
  nvidia-driver-cuda
  libva-nvidia-driver
  nvidia-persistenced
  nvidia-driver-common
  nvidia-driver-selinux
  nvidia-driver-cuda-libs
  nvidia-driver-NvFBCOpenGL
)

NVIDIA_X11=(
  nvidia-xconfig
  xorg-x11-nvidia
)

NVIDIA_CONTAINER_TOOLKIT=(
  nvidia-container-toolkit
  nvidia-container-services
  nvidia-container-toolkit-selinux
)

NVIDIA_TOOLS_APP=(
  prime-run
  nvidia-settings
)

# 32-bit (i686) NVIDIA userspace libs — only needed on *-gx / *-gx-nvidia
# images for Wine/Proton/Steam. The rest of the 32-bit gaming stack
# (mesa, audio, X11, injection libs) is installed separately by
# multilib.sh, so it isn't duplicated here.
NVIDIA_MULTILIB=(
  libnvidia-fbc.i686
  nvidia-driver-libs.i686
  nvidia-driver-common.i686
  nvidia-driver-cuda-libs.i686
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${NVIDIA_X11[@]}"
  "${NVIDIA_KMODS[@]}"
  "${NVIDIA_USERSPACE[@]}"
  "${NVIDIA_TOOLS_APP[@]}"
  "${NVIDIA_CONTAINER_TOOLKIT[@]}"
)

# Add 32-bit NVIDIA libs when building a -gx / -gx- (gaming) variant
case "${IMAGE_NAME:-}" in
  *-gx|*-gx-*) ALL_PACKAGES+=("${NVIDIA_MULTILIB[@]}") ;;
  *) : ;;
esac

dnf install --setopt=install_weak_deps=False -y "${ALL_PACKAGES[@]}"

# Nvidia Services
systemctl enable nvidia-persistenced.service
systemctl enable nvidia-powerd.service
systemctl enable nvidia-cdi.service

# Fix Kmods Tree & loading
depmod -a "${KERNEL_VERSION}"
sed -i 's/omit_drivers/force_drivers/g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's/ nvidia / i915 amdgpu nvidia /g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Remove useless nvidia files
rm -rf /usr/bin/nvidia-boot-update
rm -rf /usr/bin//usr/bin/nvidia-bug-report.sh

# Cleanup
dnf config-manager setopt fedora-nvidia.enabled=0
rm -f /etc/yum.repos.d/fedora-nvidia.repo
