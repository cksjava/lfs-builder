#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / Python
# Generated from book; do not edit — re-run generate_scripts.py
# Python
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/Python"
log_begin
trap 'log_fail $?' ERR

# Package: Python
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "Python-3.14.3" ]; then
  log "Removing prior Python-3.14.3 tree"
  rm -rf "Python-3.14.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 Python-3.14.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "Python-3.14.3" ]; then
  die "Source tarball not found matching Python-3.14.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "Python-3.14.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "Python-3.14.3" ] || die "Missing source directory Python-3.14.3"
cd "Python-3.14.3"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 3 'configure'
./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

log_step 2 3 'make'
make

log_step 3 3 'make install'
make install

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree Python-3.14.3"
rm -rf "Python-3.14.3"

trap - ERR
log_done

