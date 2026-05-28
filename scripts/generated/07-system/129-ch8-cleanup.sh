#!/bin/bash
# LFS 13.0-systemd — 07-system / ch8-cleanup
# Generated from book; do not edit — re-run generate_scripts.py
# cleanup
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/ch8-cleanup"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

log_step 1 4 'rm -rf /tmp/{*,.*}'
rm -rf /tmp/{*,.*}

log_step 2 4 'find /usr/lib /usr/libexec -name \*.la -delete'
find /usr/lib /usr/libexec -name \*.la -delete

log_step 3 4 'find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf'
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

log_step 4 4 'userdel -r tester'
userdel -r tester

trap - ERR
log_done

