#!/bin/bash
# Unmount LFS virtual filesystems and target partition (cleanup mode).
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
LFS_STEP_ID="cleanup"
log_begin

require_root

LFS="${LFS_MOUNT:-/mnt/lfs}"

log_step 1 4 "unmount virtual kernel filesystems"
umount -lv "${LFS}/dev/pts" 2>/dev/null || true
umount -lv "${LFS}/dev/shm" 2>/dev/null || true
umount -lv "${LFS}/dev" 2>/dev/null || true
umount -lv "${LFS}/run" 2>/dev/null || true
umount -lv "${LFS}/proc" 2>/dev/null || true
umount -lv "${LFS}/sys" 2>/dev/null || true

log_step 2 4 "unmount boot partition (if any)"
if [[ "${LFS_SEPARATE_BOOT:-0}" == "1" ]]; then
  umount -lv "${LFS}${LFS_BOOT_MOUNT:-/boot}" 2>/dev/null || true
fi

log_step 3 4 "unmount LFS root"
umount -lv "${LFS}" 2>/dev/null || true

log_step 4 4 "disable swap (if any)"
if [[ -n "${LFS_SWAP_DEVICE:-}" ]]; then
  swapoff "${LFS_SWAP_DEVICE}" 2>/dev/null || true
fi

log_done
