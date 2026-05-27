#!/bin/bash
# LFS 13.0-systemd — 08-config / console
# Generated from book; do not edit — re-run generate_scripts.py
# console
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
echo FONT=Lat2-Terminus16 > /etc/vconsole.conf
cat > /etc/vconsole.conf << "EOF"
KEYMAP="$LFS_KEYMAP"
FONT=Lat2-Terminus16
EOF
localectl set-keymap MAP
localectl set-x11-keymap LAYOUT [MODEL] [VARIANT] [OPTIONS]
CHROOT_EOF
