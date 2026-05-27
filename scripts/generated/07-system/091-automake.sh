#!/bin/bash
# LFS 13.0-systemd — 07-system / automake
# Generated from book; do not edit — re-run generate_scripts.py
# automake
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/automake"
log_begin
trap 'log_fail $?' ERR

# Package: automake
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 automake-1.18.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "automake-1.18.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "automake-1.18.1"
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

log_step 1 4 'configure'
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1

log_step 2 4 'make'
make

log_step 3 4 'make'
make -j$(($(nproc)>4?$(nproc):4)) check

log_step 4 4 'make install'
make install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

