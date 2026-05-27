#!/bin/bash
# LFS 13.0-systemd — 07-system / cleanup
# Generated from book; do not edit — re-run generate_scripts.py
# cleanup
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/cleanup"
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

log_step 1 4 'rm -rf /tmp/{*,.*}'
rm -rf /tmp/{*,.*}

log_step 2 4 'find /usr/lib /usr/libexec -name \*.la -delete'
find /usr/lib /usr/libexec -name \*.la -delete

log_step 3 4 'find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf'
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

log_step 4 4 'userdel -r tester'
userdel -r tester

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

