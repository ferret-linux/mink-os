#!/bin/bash

set -ouex pipefail

### Rebuild initramfs

# rpm-ostree wraps dracut for use inside the build; fall back to the
# regular binary if that wrapper isn't present.
if [ -f "/usr/libexec/rpm-ostree/wrapped/dracut" ]; then
    DRACUT="/usr/libexec/rpm-ostree/wrapped/dracut"
else
    DRACUT="/usr/bin/dracut"
fi

# Quiet dracut's logging for the duration of this build only.
temp_conf_file="$(mktemp '/etc/dracut.conf.d/zzz-loglevels-XXXXXXXXXX.conf')"
cat >"${temp_conf_file}" <<'EOF'
stdloglvl=4
sysloglvl=0
kmsgloglvl=0
fileloglvl=0
EOF

for kernel_path in /usr/lib/modules/*/; do
    kernel_path="${kernel_path%/}"
    initramfs_image="${kernel_path}/initramfs.img"
    qual_kernel="${kernel_path##*/}"
    echo "Rebuilding initramfs for kernel: ${qual_kernel}"
    "${DRACUT}" \
        --force \
        --strip \
        --nolvmconf \
        --nomdadmconf \
        --no-hostonly \
        --add 'ostree' \
        --reproducible \
        --aggressive-strip \
        --no-hostonly-i18n \
        --no-hostonly-nics \
        --no-hostonly-cmdline \
        --kver "${qual_kernel}" \
        --filesystems 'overlay' \
        --no-hostonly-default-device \
        --compress="zstd -22 --ultra -T0" \
        "${initramfs_image}"
    chmod 0600 "${initramfs_image}"
done

rm -- "${temp_conf_file}"