#!/bin/bash
# LFS 13.0-systemd — 08-config / systemd-custom
# Generated from book; do not edit — re-run generate_scripts.py
# systemd-custom
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="08-config/systemd-custom"
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

log_step 1 8 'mkdir -pv /etc/systemd/system/getty@tty1.service.d'
mkdir -pv /etc/systemd/system/getty@tty1.service.d

log_step 2 8 'write configuration file'
cat > /etc/systemd/system/getty@tty1.service.d/noclear.conf << EOF
[Service]
TTYVTDisallocate=no
EOF

log_step 3 8 'ln -sfv /dev/null /etc/systemd/system/tmp.mount'
ln -sfv /dev/null /etc/systemd/system/tmp.mount

log_step 4 8 'mkdir -p /etc/tmpfiles.d'
mkdir -p /etc/tmpfiles.d
cp /usr/lib/tmpfiles.d/tmp.conf /etc/tmpfiles.d

log_step 5 8 'mkdir -pv /etc/systemd/system/foobar.service.d'
mkdir -pv /etc/systemd/system/foobar.service.d

log_step 6 8 'write configuration file'
cat > /etc/systemd/system/foobar.service.d/foobar.conf << EOF
[Service]
Restart=always
RestartSec=30
EOF

log_step 7 8 'mkdir -pv /etc/systemd/coredump.conf.d'
mkdir -pv /etc/systemd/coredump.conf.d

log_step 8 8 'write configuration file'
cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
[Coredump]
MaxUse=5G
EOF

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

