#!/bin/bash
# Format and mount LFS partition(s) per chapter 2.
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
LFS_STEP_ID="01-partition"
log_begin
trap 'log_fail $?' ERR

require_root
require_var LFS_MOUNT
require_var LFS_DEVICE
require_var LFS_FILESYSTEM

log_step 1 5 "verify block device ${LFS_DEVICE}"
if [ ! -b "${LFS_DEVICE}" ]; then
  log "Block devices:"
  lsblk
  die "${LFS_DEVICE} is not a block device — check lsblk and re-run the wizard"
fi

log_step 2 5 "create filesystem if needed"
fs_type="$(blkid -o value -s TYPE "${LFS_DEVICE}" 2>/dev/null || true)"
if [ "${fs_type}" != "${LFS_FILESYSTEM}" ]; then
  if [ -n "${fs_type}" ]; then
    log "Found ${fs_type} on ${LFS_DEVICE}; reformatting as ${LFS_FILESYSTEM}"
  else
    log "No filesystem on ${LFS_DEVICE}; creating ${LFS_FILESYSTEM}"
  fi
  case "${LFS_FILESYSTEM}" in
    ext4) mkfs.ext4 -F "${LFS_DEVICE}" ;;
    ext3) mkfs.ext3 -F "${LFS_DEVICE}" ;;
    xfs)  mkfs.xfs -f "${LFS_DEVICE}" ;;
    btrfs) mkfs.btrfs -f "${LFS_DEVICE}" ;;
    *) die "Unsupported filesystem: ${LFS_FILESYSTEM}" ;;
  esac
fi

log_step 3 5 "mount LFS partition at ${LFS_MOUNT}"
mkdir -pv "${LFS_MOUNT}"
if ! mountpoint -q "${LFS_MOUNT}"; then
  mount -v -t "${LFS_FILESYSTEM}" "${LFS_DEVICE}" "${LFS_MOUNT}"
fi

log_step 4 5 "mount optional boot partition"
if [[ "${LFS_SEPARATE_BOOT:-0}" == "1" && -n "${LFS_BOOT_DEVICE:-}" ]]; then
  mkdir -pv "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"
  if ! mountpoint -q "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"; then
    mount -v "${LFS_BOOT_DEVICE}" "${LFS_MOUNT}${LFS_BOOT_MOUNT:-/boot}"
  fi
else
  log "no separate boot partition"
fi

log_step 5 5 "enable swap if configured"
if [[ -n "${LFS_SWAP_DEVICE:-}" ]]; then
  if ! swapon --show | grep -q "${LFS_SWAP_DEVICE}"; then
    log "Enabling swap on ${LFS_SWAP_DEVICE}"
    swapon "${LFS_SWAP_DEVICE}" || log "Warning: could not enable swap"
  fi
else
  log "no swap partition configured"
fi

export LFS="${LFS_MOUNT}"
umask 022
trap - ERR
log_done
