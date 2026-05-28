#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / cleanup
# Generated from book; do not edit — re-run generate_scripts.py
# cleanup
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/cleanup"
log_begin
trap 'log_fail $?' ERR

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 6 'rm -rf /usr/share/{info,man,doc}/*'
rm -rf /usr/share/{info,man,doc}/*

log_step 2 6 'find /usr/{lib,libexec} -name \*.la -delete'
find /usr/{lib,libexec} -name \*.la -delete

log_step 3 6 'rm -rf /tools'
rm -rf /tools

log_step 4 6 'exit'
exit

log_step 5 6 'mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm'
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

log_step 6 6 'extract source archive'
cd $LFS
tar -cJpf $HOME/lfs-temp-tools-13.0-systemd.tar.xz .

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

