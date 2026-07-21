#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Keep these separated/commented for readability;
# they all get flattened into ONE dnf transaction below.
# ---------------------------------------------------------------------------

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

LXC=(
  lxc
  criu
  lxcfs
  lxc-libs
  lxc-templates
)

COCKPIT=(
  cockpit
  cockpit-ws
  cockpit-files
  cockpit-bridge
  cockpit-ostree
  cockpit-podman
  cockpit-system
  cockpit-selinux
  cockpit-storaged
  cockpit-machines
  cockpit-ws-selinux
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
  waydroid
  android-tools
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
  "${DOCKER[@]}"
  "${PODMAN[@]}"
  "${LXC[@]}"
  "${COCKPIT[@]}"
  "${CLI_UTILS[@]}"
  "${GIT_TOOLS[@]}"
  "${MUSL_TOOLCHAIN[@]}"
  "${DEV_TOOLS[@]}"
  "${FUSE_TOOLS[@]}"
  "${AUDIO[@]}"
  "${GSTREAMER[@]}"
)

dnf install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"

# Settings
systemctl enable containerd.service
systemctl enable docker.service
systemctl enable cockpit.socket
systemctl enable docker.socket
systemctl enable podman.socket