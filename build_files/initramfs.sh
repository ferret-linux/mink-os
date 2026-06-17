#!/bin/bash

set -ouex pipefail

### Rebuild initramfs
if [ -f "/usr/libexec/rpm-ostree/wrapped/dracut" ]; then
    DRACUT="/usr/libexec/rpm-ostree/wrapped/dracut"
else
    DRACUT="/usr/bin/dracut"
fi

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
        --kver "${qual_kernel}" \
        --force \
        --add 'ostree' \
        --no-hostonly \
        --reproducible \
        "${initramfs_image}"
    chmod 0600 "${initramfs_image}"
done

rm -- "${temp_conf_file}"