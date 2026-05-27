#!/bin/bash
# LFS 13.0-systemd — 08-config / console
# Generated from book; do not edit — re-run generate_scripts.py
# console
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="08-config/console"
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

log_step 1 4 'echo FONT=Lat2-Terminus16 > /etc/vconsole.conf'
echo FONT=Lat2-Terminus16 > /etc/vconsole.conf

log_step 2 4 'write configuration file'
cat > /etc/vconsole.conf << "EOF"
KEYMAP="$LFS_KEYMAP"
FONT=Lat2-Terminus16
EOF

log_step 3 4 'localectl set-keymap MAP'
localectl set-keymap MAP

log_step 4 4 'localectl set-x11-keymap LAYOUT [MODEL] [VARIANT] [OPTIONS]'
localectl set-x11-keymap LAYOUT [MODEL] [VARIANT] [OPTIONS]

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

