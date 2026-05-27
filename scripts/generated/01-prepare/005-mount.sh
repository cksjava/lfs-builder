#!/bin/bash
# LFS 13.0-systemd — 01-prepare / mount
# Generated from book; do not edit — re-run generate_scripts.py
# mounting
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="01-prepare/mount"
log_begin
trap 'log_fail $?' ERR

require_var LFS
[ -d "${LFS}" ] || die "LFS not mounted — run partition step first"
log_step 1 2 "set LFS mount ownership"
chown root:root "${LFS}" 2>/dev/null || true
log_step 2 2 "set LFS mount permissions"
chmod 755 "${LFS}"
trap - ERR
log_done

