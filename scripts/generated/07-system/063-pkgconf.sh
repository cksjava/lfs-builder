#!/bin/bash
# LFS 13.0-systemd — 07-system / pkgconf
# Generated from book; do not edit — re-run generate_scripts.py
# pkgconf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/pkgconf"
log_begin
trap 'log_fail $?' ERR

# Package: pkgconf
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 pkgconf-2.5.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "pkgconf-2.5.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "pkgconf-2.5.1"
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
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

log_step 2 4 'make'
make

log_step 3 4 'make install'
make install

log_step 4 4 'ln -sv pkgconf   /usr/bin/pkg-config'
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

