#!/bin/bash
# Unmount LFS virtual filesystems and target partition (cleanup mode).
source "$(dirname "$0")/../lib/common.sh"
require_root

LFS="${LFS_MOUNT:-/mnt/lfs}"

log "Unmounting virtual kernel filesystems under ${LFS}"

umount -lv "${LFS}/dev/pts" 2>/dev/null || true
umount -lv "${LFS}/dev/shm" 2>/dev/null || true
umount -lv "${LFS}/dev" 2>/dev/null || true
umount -lv "${LFS}/run" 2>/dev/null || true
umount -lv "${LFS}/proc" 2>/dev/null || true
umount -lv "${LFS}/sys" 2>/dev/null || true

if [[ "${LFS_SEPARATE_BOOT:-0}" == "1" ]]; then
  umount -lv "${LFS}${LFS_BOOT_MOUNT:-/boot}" 2>/dev/null || true
fi

umount -lv "${LFS}" 2>/dev/null || true

if [[ -n "${LFS_SWAP_DEVICE:-}" ]]; then
  swapoff "${LFS_SWAP_DEVICE}" 2>/dev/null || true
fi

log "Cleanup unmount complete"
