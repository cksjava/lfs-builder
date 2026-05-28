#!/bin/bash
# LFS 13.0-systemd — 08-config / symlinks
# Generated from book; do not edit — re-run generate_scripts.py
# symlinks
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/symlinks"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

log_step 1 4 'udevadm info -a -p /sys/class/video4linux/video0'
udevadm info -a -p /sys/class/video4linux/video0

log_step 2 4 'write configuration file'
cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

log_step 3 4 '# Persistent symlinks for webcam and tuner'
# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f",  ATTRS{vendor}=="0x109e", SYMLINK+="tvtuner"

log_step 4 4 'EOF'
EOF

trap - ERR
log_done

