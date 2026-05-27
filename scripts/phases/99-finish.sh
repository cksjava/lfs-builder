#!/bin/bash
# Post-build: exit chroot context and prepare for reboot (chapter 11).
source "$(dirname "$0")/../lib/common.sh"
require_root
require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"

log "Build complete. To boot your new LFS system:"
log "  1. Exit any chroot shell if still inside"
log "  2. Run: $(dirname "$0")/cleanup.sh  (or: build_lfs.py --cleanup)"
log "  3. Reboot and select your LFS kernel from GRUB"
log ""
log "Root filesystem: ${LFS}"
log "Hostname: ${LFS_HOSTNAME:-lfs}"
