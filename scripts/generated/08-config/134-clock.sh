#!/bin/bash
# LFS 13.0-systemd — 08-config / clock
# Generated from book; do not edit — re-run generate_scripts.py
# clock
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
cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF
timedatectl set-local-rtc 1
timedatectl set-time YYYY-MM-DD HH:MM:SS
timedatectl set-timezone TIMEZONE
timedatectl list-timezones
systemctl disable systemd-timesyncd
CHROOT_EOF
