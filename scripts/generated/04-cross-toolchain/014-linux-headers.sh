#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / linux-headers
# Generated from book; do not edit — re-run generate_scripts.py
# linux-headers
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/linux-headers"
log_begin
trap 'log_fail $?' ERR

log_step 1 2 'make'
make mrproper

log_step 2 2 'make'
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

trap - ERR
log_done

