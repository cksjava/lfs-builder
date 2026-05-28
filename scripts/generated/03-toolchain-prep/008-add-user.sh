#!/bin/bash
# LFS 13.0-systemd — 03-toolchain-prep / add-user
# Generated from book; do not edit — re-run generate_scripts.py
# addinguser
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="03-toolchain-prep/add-user"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

log_step 1 2 'getent group lfs &>/dev/null || groupadd lfs'
getent group lfs &>/dev/null || groupadd lfs
getent passwd lfs &>/dev/null || useradd -s /bin/bash -g lfs -m -k /dev/null lfs

log_step 2 2 'chown -v lfs $LFS/{usr{,/*},var,etc,tools}'
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac

trap - ERR
log_done

