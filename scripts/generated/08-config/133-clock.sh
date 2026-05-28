#!/bin/bash
# LFS 13.0-systemd — 08-config / clock
# Generated from book; do not edit — re-run generate_scripts.py
# clock
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/clock"
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

log_step 1 6 'write configuration file'
cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF

log_step 2 6 'timedatectl set-local-rtc 1'
timedatectl set-local-rtc 1

log_step 3 6 'timedatectl set-time YYYY-MM-DD HH:MM:SS'
timedatectl set-time YYYY-MM-DD HH:MM:SS

log_step 4 6 'timedatectl set-timezone TIMEZONE'
timedatectl set-timezone TIMEZONE

log_step 5 6 'timedatectl list-timezones'
timedatectl list-timezones

log_step 6 6 'systemctl disable systemd-timesyncd'
systemctl disable systemd-timesyncd

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

