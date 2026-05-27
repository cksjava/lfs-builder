#!/bin/bash
# LFS 13.0-systemd — 09-bootable / grub
# Generated from book; do not edit — re-run generate_scripts.py
# grub
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="09-bootable/grub"
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

log_step 1 5 'cd /tmp'
cd /tmp
grub-mkrescue --output=grub-img.iso
xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso

log_step 2 5 'grub-install /dev/sda'
grub-install /dev/sda

log_step 3 5 'write configuration file'
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

log_step 4 5 'insmod part_gpt'
insmod part_gpt
insmod ext2
set root=(hd0,2)
set gfxpayload=1024x768x32

log_step 5 5 'menuentry "GNU/Linux, Linux 6.18.10-lfs-13.0-systemd" {'
menuentry "GNU/Linux, Linux 6.18.10-lfs-13.0-systemd" {
        linux   /boot/vmlinuz-6.18.10-lfs-13.0-systemd root=/dev/sda2 ro
}
EOF

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

