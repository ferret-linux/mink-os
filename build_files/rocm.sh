#!/bin/bash
set -euxo pipefail

# Env-Vars
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1)"

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

ROCM_GPU=(
  rocm
  rocm-hip
  rocm-smi
  rocm-opencl
  rocm-clinfo
)

ONEAPI_GPU=(
  onednn
  intel-level-zero
  oneapi-level-zero
  intel-compute-runtime
  intel-level-zero-devel
  oneapi-level-zero-devel
  intel-level-zero-gpu-raytracing
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf transaction. Order in the array doesn't matter to dnf's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${ROCM_GPU[@]}"
  "${ONEAPI_GPU[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Rebuild module dependencies (kernel modules are now installed above)
depmod -a "${KERNEL_VERSION}"