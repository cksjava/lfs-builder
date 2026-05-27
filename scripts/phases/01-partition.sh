#!/bin/bash
# Format and mount LFS partition(s) per chapter 2.
source "$(dirname "$0")/../lib/common.sh"
require_root
require_var LFS_MOUNT
require_var LFS_DEVICE
require_var LFS_FILESYSTEM

log "Preparing LFS partition ${LFS_DEVICE} -> ${LFS_MOUNT}"

if ! blkid "${LFS_DEVICE}" &>/dev/null; then
  log "Creating ${LFS_FILESYSTEM} on ${LFS_DEVICE}"
  case "${LFS_FILESYSTEM}" in
    ext4) mkfs.ext4 -F "${LFS_DEVICE}" ;;
    ext3) mkfs.ext3 -F "${LFS_DEVICE}" ;;
    xfs)  mkfs.xfs -f "${LFS_DEVICE}" ;;
    btrfs) mkfs.btrfs -f "${LFS_DEVICE}" ;;
    *) die "Unsupported filesystem: ${LFS_FILESYSTEM}" ;;
  esac
fi

mkdir -pv "${LFS_MOUNT}"
if ! mountpoint -q "${LFS_MOUNT}"; then
  mount -v -t "${LFS_FILESYSTEM}" "${LFS_DEVICE}" "${LFS_MOUNT}"
fi

if [[ "${LFS_SEPARATE_BOOT:-0}" == "1" && -n "${LFS_BOOT_DEVICE:-}" ]]; then
  mkdir -pv "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"
  if ! mountpoint -q "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"; then
    mount -v "${LFS_BOOT_DEVICE}" "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"
  fi
fi

if [[ -n "${LFS_SWAP_DEVICE:-}" ]]; then
  if ! swapon --show | grep -q "${LFS_SWAP_DEVICE}"; then
    log "Enabling swap on ${LFS_SWAP_DEVICE}"
    swapon "${LFS_SWAP_DEVICE}" || log "Warning: could not enable swap"
  fi
fi

export LFS="${LFS_MOUNT}"
umask 022
log "Partition ready at LFS=${LFS}"
