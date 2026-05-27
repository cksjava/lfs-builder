#!/bin/bash
# LFS 13.0-systemd — 09-bootable / fstab
# Generated from book; do not edit — re-run generate_scripts.py
# fstab
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
cat > /etc/fstab << "EOF"
# Begin /etc/fstab
# file system  mount-point  type     options             dump  fsck
#                                                              order
"$LFS_DEVICE"     /            <fff>    defaults            1     1
"$LFS_DEVICE"     swap         swap     pri=1               0     0
# End /etc/fstab
EOF
CHROOT_EOF
