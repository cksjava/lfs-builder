#!/bin/bash
# LFS 13.0-systemd — 07-system / lz4
# Generated from book; do not edit — re-run generate_scripts.py
# lz4
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/lz4"
log_begin
trap 'log_fail $?' ERR

# Package: lz4
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 lz4-1.10.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "lz4-1.10.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "lz4-1.10.0"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 3 'make'
make BUILD_STATIC=no PREFIX=/usr

log_step 2 3 'make'
make -j1 check

log_step 3 3 'make'
make BUILD_STATIC=no PREFIX=/usr install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

