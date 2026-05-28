#!/bin/bash
# LFS 13.0-systemd — 08-config / systemd-custom
# Generated from book; do not edit — re-run generate_scripts.py
# systemd-custom
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/systemd-custom"
log_begin
trap 'log_fail $?' ERR

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

trap - ERR
log_done

