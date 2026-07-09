#!/bin/bash

set -ouex pipefail

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