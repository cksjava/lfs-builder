#!/bin/bash
# LFS 13.0-systemd — 08-config / console
# Generated from book; do not edit — re-run generate_scripts.py
# console
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/console"
log_begin
trap 'log_fail $?' ERR

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

trap - ERR
log_done

