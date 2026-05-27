#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / chroot-enter
# Generated from book; do not edit — re-run generate_scripts.py
# chroot
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/chroot-enter"
log_begin
trap 'log_fail $?' ERR

require_var LFS

trap - ERR
log_done

