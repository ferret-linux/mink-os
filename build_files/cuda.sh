#!/bin/bash

set -ouex pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# Add Nvidia Drivers Repo
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager setopt fedora-nvidia.enabled=1
dnf config-manager setopt fedora-nvidia.priority=70
dnf makecache --refresh

NVIDIA_CUDA_TOOLKIT=(
  cuda
  cuda-gcc
  cuda-libs
  cuda-devel
  cuda-extra-libs
  criu-cuda-plugin
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${NVIDIA_CUDA_TOOLKIT[@]}"
)

dnf install --setopt=install_weak_deps=False -y "${ALL_PACKAGES[@]}"

# Cleanup
dnf config-manager setopt fedora-nvidia.enabled=0
rm -f /etc/yum.repos.d/fedora-nvidia.repo

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"