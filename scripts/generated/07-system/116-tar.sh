#!/bin/bash
# LFS 13.0-systemd — 07-system / tar
# Generated from book; do not edit — re-run generate_scripts.py
# tar
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/tar"
log_begin
trap 'log_fail $?' ERR

# Package: tar
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 tar-1.35*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "tar-1.35" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "tar-1.35"
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
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
make check

log_step 4 4 'make install'
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

