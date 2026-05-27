#!/bin/bash
# LFS 13.0-systemd — 08-config / udev
# Generated from book; do not edit — re-run generate_scripts.py
# udev
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="08-config/udev"
log_begin
trap 'log_fail $?' ERR

trap - ERR
log_done

