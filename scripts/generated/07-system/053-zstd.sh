#!/bin/bash
# LFS 13.0-systemd — 07-system / zstd
# Generated from book; do not edit — re-run generate_scripts.py
# zstd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/zstd"
log_begin
trap 'log_fail $?' ERR

# Package: zstd
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 zstd-1.5.7*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "zstd-1.5.7" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "zstd-1.5.7"
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

log_step 1 4 'make'
make prefix=/usr

log_step 2 4 'make check (test suite)'
make check

log_step 3 4 'make'
make prefix=/usr install

log_step 4 4 'rm -v /usr/lib/libzstd.a'
rm -v /usr/lib/libzstd.a

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

