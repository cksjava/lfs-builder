#!/bin/bash
# LFS 13.0-systemd — 09-bootable / fstab
# Generated from book; do not edit — re-run generate_scripts.py
# fstab
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="09-bootable/fstab"
log_begin
trap 'log_fail $?' ERR

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 4 'write configuration file'
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

log_step 2 4 '# file system  mount-point  type     options             dump  fsck'
# file system  mount-point  type     options             dump  fsck
#                                                              order

log_step 3 4 '"$LFS_DEVICE"     /            <fff>    defaults            1     1'
"$LFS_DEVICE"     /            <fff>    defaults            1     1
"$LFS_DEVICE"     swap         swap     pri=1               0     0

log_step 4 4 '# End /etc/fstab'
# End /etc/fstab
EOF

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

