ARG BASE_IMAGE

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ${BASE_IMAGE}

ARG IMAGE_NAME
ENV IMAGE_NAME=${IMAGE_NAME}

# Make /opt real dir before package install
RUN rm -rf /opt && mkdir -p /opt

# Add Ferret repos & remove fedora repos
RUN dnf install -y --setopt=install_weak_deps=False dnf5-plugins && \
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo && \
    dnf config-manager addrepo --from-repofile=https://ferretlinux.org/repo/ferret-kmods.repo && \
    dnf config-manager addrepo --from-repofile=https://ferretlinux.org/repo/ferret-pkgs.repo && \
    dnf config-manager setopt fedora-multimedia.enabled=1 && \
    dnf config-manager setopt ferret-kmods.enabled=1 && \
    dnf config-manager setopt ferret-pkgs.enabled=1 && \
    dnf config-manager setopt fedora-multimedia.priority=90 && \
    dnf config-manager setopt ferret-kmods.priority=90 && \
    dnf config-manager setopt ferret-pkgs.priority=90 && \
    dnf remove -y fedora-repos-archive && \
    rm -f /etc/yum.repos.d/fedora-updates-testing.repo && \
    rm -f /etc/yum.repos.d/fedora-updates-archive.repo && \
    rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo && \
    dnf autoremove -y && \
    dnf clean packages && \
    dnf clean all && \
    dnf upgrade --refresh --setopt=install_weak_deps=False -y

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build.sh

# Move /opt contents to immutable tree, create tmpfiles.d entries, fix dirs
RUN mkdir -p /usr/lib/opt && \
    mv /opt/* /usr/lib/opt/ 2>/dev/null || true && \
    for dir in /usr/lib/opt/*/; do \
        opt=$(basename "$dir"); \
        echo "L+?  \"/opt/${opt}\"  -  -  -  -  /usr/lib/opt/${opt}" > /usr/lib/tmpfiles.d/99-optfix-${opt}.conf; \
    done

# Add Settings Package & settings
RUN sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd && \
    rm -rf /usr/share/plymouth/themes/charge && \
    rm -rf /usr/share/plymouth/themes/details && \
    rm -rf /usr/share/plymouth/themes/spinner && \
    rm -rf /usr/share/plymouth/themes/text && \
    rm -rf /usr/share/plymouth/themes/tribar

# Disable Broken Services
RUN systemctl mask systemd-remount-fs.service && \
    systemctl disable bootc-fetch-apply-updates.timer && \
    systemctl mask bootc-fetch-apply-updates.timer && \
    systemctl disable flatpak-add-fedora-repos.service && \
    systemctl mask flatpak-add-fedora-repos.service

# Enable Our Services
RUN systemctl enable ferret-libvirt-fix.service && \
    systemctl enable systemd-timesyncd.service && \
    systemctl enable ferret-hostname.service && \
    systemctl enable ferret-flatpak.service && \
    systemctl enable ferret-groups.service && \
    systemctl enable ferret-rfkill.service && \
    systemctl enable nix-daemon && \
    systemctl enable nix.mount

# Set Plymouth theme
RUN plymouth-set-default-theme zomac

# Remove Fedora specific bloat
RUN dnf remove -y \
    nano \
    htop \
    nvtop \
    micro \
    chrony \
    toolbox \
    firefox \
    fdk-aac-free \
    firefox-langpacks \
    fedora-repos-archive \
    glibc-minimal-langpack \
    jack-audio-connection-kit \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras

# Final Build steps/cleanup
RUN dnf config-manager setopt fedora-multimedia.enabled=0 && \
    dnf config-manager setopt ferret-kmods.enabled=0 && \
    dnf config-manager setopt ferret-pkgs.enabled=0 && \
    rm -f /etc/yum.repos.d/fedora-multimedia.repo && \
    rm -f /etc/yum.repos.d/ferret-kmods.repo && \
    rm -f /etc/yum.repos.d/ferret-pkgs.repo && \
    dnf5 autoremove -y && \
    dnf5 clean packages && \
    dnf5 clean all

# Fix Directories
RUN rm -rf /opt && ln -s /var/opt /opt && \
    mkdir -p /var/roothome && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /nix && \
    mkdir -p /var/nix

# Edit OS-release
RUN sed -i 's/^NAME=.*/NAME="MinkOS"/' /usr/lib/os-release && \
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="MinkOS Linux"/' /usr/lib/os-release

# Copy system files
COPY system_files/ /

# Generate InitRamFs
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/initramfs.sh

# Lock all packages (makes build easier)
RUN dnf versionlock add $(rpm -qa --qf '%{NAME}\n')

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint