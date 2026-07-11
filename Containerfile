# ==============================================================
#  MinkOS container image build
#  Base: ${BASE_IMAGE}
# ==============================================================

ARG BASE_IMAGE

# ── Build context ─────────────────────────────────────────────
# Allow build scripts and system_files overlays to be referenced
# without being copied into the final image directly.
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# ── Base image ───────────────────────────────────────────────
FROM ${BASE_IMAGE}

ARG IMAGE_NAME
ENV IMAGE_NAME=${IMAGE_NAME}

# Make /opt a real directory before package install (some packages
# expect to write here directly).
RUN rm -rf /opt && mkdir -p /opt

# Make install_weak_deps=False default
RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

# ── Repositories: add Ferret/negativo17, strip Fedora repos ─────
RUN dnf install -y --refresh --setopt=install_weak_deps=False dnf5-plugins && \
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo && \
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-cdrtools.repo && \
    dnf config-manager addrepo --from-repofile=https://ferretlinux.org/repo/ferret-kmods.repo && \
    dnf config-manager addrepo --from-repofile=https://ferretlinux.org/repo/ferret-pkgs.repo && \
    dnf config-manager setopt fedora-multimedia.enabled=1 && \
    dnf config-manager setopt fedora-cdrtools.enabled=1 && \
    dnf config-manager setopt ferret-kmods.enabled=1 && \
    dnf config-manager setopt ferret-pkgs.enabled=1 && \
    dnf config-manager setopt fedora-multimedia.priority=80 && \
    dnf config-manager setopt fedora-cdrtools.priority=90 && \
    dnf config-manager setopt ferret-kmods.priority=50 && \
    dnf config-manager setopt ferret-pkgs.priority=60 && \
    dnf remove -y fedora-repos-archive && \
    rm -f /etc/yum.repos.d/fedora-updates-testing.repo && \
    rm -f /etc/yum.repos.d/fedora-updates-archive.repo && \
    rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo && \
    dnf autoremove -y && \
    dnf clean packages && \
    dnf clean all

RUN dnf --refresh makecache && dnf upgrade --setopt=install_weak_deps=False -y

# ── Mini packages (ALL image variants) ─────────────────────────
# The minimal/core package set. Every single image flavor gets this,
# including the *-mini and *-mini-nvidia variants.
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/mini.sh

# ── Essentials packages (all variants EXCEPT *-mini / *-mini-nvidia) ──
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-mini|*-mini-nvidia) : ;; \
        *) bash /ctx/essentials.sh ;; \
    esac

# ── NVIDIA drivers (*-nvidia image variants only) ──────────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-nvidia) bash /ctx/nvidia.sh ;; \
        *) : ;; \
    esac

# ── Developer packages (*-dx / *-dx-nvidia image variants only) ─
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-dx|*-dx-*) bash /ctx/dx-setup.sh ;; \
        *) : ;; \
    esac

# ── Gaming packages (*-gx / *-gx-nvidia image variants only) ────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-gx|*-gx-*) bash /ctx/gx-setup.sh ;; \
        *) : ;; \
    esac

# ── CUDA packages (*-dx-nvidia image variant only) ──────────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-dx-nvidia) bash /ctx/cuda.sh ;; \
        *) : ;; \
    esac

# ── ROCm packages (*-dx image variant only, non-nvidia) ─────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-dx) bash /ctx/rocm.sh ;; \
        *) : ;; \
    esac

# ── /opt → immutable tree migration ───────────────────────────
# Move /opt contents into the immutable /usr tree and create
# tmpfiles.d entries to symlink them back at runtime.
RUN mkdir -p /usr/lib/opt && \
    mv /opt/* /usr/lib/opt/ 2>/dev/null || true && \
    for dir in /usr/lib/opt/*/; do \
        opt=$(basename "$dir"); \
        echo "L+?  \"/opt/${opt}\"  -  -  -  -  /usr/lib/opt/${opt}" > /usr/lib/tmpfiles.d/99-optfix-${opt}.conf; \
    done

# ── Remove Fedora-specific bloat ──────────────────────────────
RUN dnf remove -y \
    nano \
    htop \
    nvtop \
    micro \
    toolbox \
    firefox \
    fdk-aac-free \
    firefox-langpacks \
    fedora-repos-archive \
    glibc-minimal-langpack \
    jack-audio-connection-kit \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras

# ── Package version lock ─────────────────────────────────────
# Lock all installed packages to their current versions/releases,
# making rebase/upgrade behavior deterministic for this image.
# (dnf5 writes this to /etc/dnf/versionlock.toml — part of the
# committed OS tree, not /var — so it persists correctly.)
RUN dnf versionlock add $(rpm -qa --qf '%{NAME}\n')

# ── Repository cleanup ───────────────────────────────────────
# Remove build-only repos so they don't ship in the final image.
RUN dnf config-manager setopt fedora-multimedia.enabled=0 && \
    dnf config-manager setopt fedora-cdrtools.enabled=0 && \
    dnf config-manager setopt ferret-kmods.enabled=0 && \
    dnf config-manager setopt ferret-pkgs.enabled=0 && \
    rm -f /etc/yum.repos.d/fedora-multimedia.repo && \
    rm -f /etc/yum.repos.d/fedora-cdrtools.repo && \
    rm -f /etc/yum.repos.d/ferret-kmods.repo && \
    rm -f /etc/yum.repos.d/ferret-pkgs.repo && \
    dnf5 autoremove -y && \
    dnf5 clean packages && \
    dnf5 clean all

# ── Directory fixes ──────────────────────────────────────────
# Replace /opt with a symlink into /var so it stays writable, and
# ensure other runtime-required directories exist with correct perms.
RUN rm -rf /opt && ln -s /var/opt /opt && \
    mkdir -p /var/roothome && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /nix && \
    mkdir -p /var/nix

# ── OS release metadata ─────────────────────────────────────────
RUN sed -i 's/^NAME=.*/NAME="MinkOS"/' /usr/lib/os-release && \
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="MinkOS Linux"/' /usr/lib/os-release

# ── System files ─────────────────────────────────────────────
# system_files/ is split per flavor (mini, essentials, dx, gx). Layer the
# matching subfolders onto the rootfs using the SAME selection logic as
# the package-install steps above:
#   mini        -> ALL variants
#   essentials  -> all variants EXCEPT *-mini / *-mini-nvidia
#   dx          -> *-dx / *-dx-nvidia variants only
#   gx          -> *-gx / *-gx-nvidia variants only
# `cp -a src/. /` merges directory contents onto root without clobbering
# the whole tree.
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    cp -a /ctx/system_files/mini/. / && \
    case "${IMAGE_NAME}" in \
        *-mini|*-mini-nvidia) : ;; \
        *) cp -a /ctx/system_files/essentials/. / ;; \
    esac && \
    case "${IMAGE_NAME}" in \
        *-dx|*-dx-*) cp -a /ctx/system_files/dx/. / ;; \
        *) : ;; \
    esac && \
    case "${IMAGE_NAME}" in \
        *-gx|*-gx-*) cp -a /ctx/system_files/gx/. / ;; \
        *) : ;; \
    esac

# ── Disable broken/unwanted services ──────────────────────────
RUN systemctl disable flatpak-add-fedora-repos.service && \
    systemctl disable bootc-fetch-apply-updates.timer && \
    systemctl disable rpm-ostree-countme.service && \
    systemctl disable rpm-ostree-countme.timer && \
    systemctl mask flatpak-add-fedora-repos.service && \
    systemctl mask bootc-fetch-apply-updates.timer && \
    systemctl mask systemd-remount-fs.service && \
    systemctl mask rpm-ostree-countme.service && \
    systemctl mask rpm-ostree-countme.timer

# ── Enable Ferret/MinkOS services ─────────────────────────────
RUN systemctl enable ferret-hostname.service && \
    systemctl enable ferret-flatpak.service && \
    systemctl enable ferret-groups.service && \
    systemctl enable ferret-rfkill.service && \
    systemctl enable nix-daemon && \
    systemctl enable nix.mount

# ── Shell defaults & Plymouth theme cleanup ───────────────────
RUN sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd && \
    rm -rf /usr/share/plymouth/themes/charge && \
    rm -rf /usr/share/plymouth/themes/details && \
    rm -rf /usr/share/plymouth/themes/spinner && \
    rm -rf /usr/share/plymouth/themes/text && \
    rm -rf /usr/share/plymouth/themes/tribar

# Set Plymouth theme
RUN plymouth-set-default-theme zomac

# ── Remove unwanted desktop entries ───────────────────────────
RUN rm -rf /usr/share/applications/input-remapper-gtk.desktop && \
    rm -rf /usr/share/applications/envy24control.desktop && \
    rm -rf /usr/share/applications/hdajackretask.desktop && \
    rm -rf /usr/share/applications/virt-manager.desktop && \
    rm -rf /usr/share/applications/hwmixvolume.desktop && \
    rm -rf /usr/share/applications/hdspmixer.desktop && \
    rm -rf /usr/share/applications/echomixer.desktop && \
    rm -rf /usr/share/applications/hdspconf.desktop && \
    rm -rf /usr/share/applications/btop.desktop && \
    rm -rf /usr/share/applications/nvim.desktop

# ── Installed package count ──────────────────────────────────
# Just a quick sanity check/log of how many packages ended up
# in the image — no version locking applied.
RUN echo "📦 Total installed packages: $(rpm -qa | wc -l)"

# ── InitRAMFS build (ALL image variants) ───────────────────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/initramfs.sh

# ── Image Cleanup (for Bootc compatibility) ──────────────────
RUN find /var/* -maxdepth 0 -type d ! -name cache ! -name log -exec rm -rf {} \; && \
    find /var/cache/* -maxdepth 0 -type d ! -name libdnf5 -exec rm -rf {} \; && \
    rm -rf /boot && mkdir -p /boot && \
    rm -rf /usr/etc

# ── Linting ──────────────────────────────────────────────────
# Verify final image and contents are correct.
RUN bootc container lint