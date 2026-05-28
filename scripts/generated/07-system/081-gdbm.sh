#!/bin/bash
# LFS 13.0-systemd — 07-system / gdbm
# Generated from book; do not edit — re-run generate_scripts.py
# gdbm
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gdbm"
log_begin
trap 'log_fail $?' ERR

# Package: gdbm
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gdbm-1.26" ]; then
  log "Removing prior gdbm-1.26 tree"
  rm -rf "gdbm-1.26"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gdbm-1.26*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gdbm-1.26" ]; then
  die "Source tarball not found matching gdbm-1.26"
fi
if [ -n "$TARBALL" ] && [ ! -d "gdbm-1.26" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gdbm-1.26" ] || die "Missing source directory gdbm-1.26"
cd "gdbm-1.26"
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

log_step 1 4 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree gdbm-1.26"
rm -rf "gdbm-1.26"

trap - ERR
log_done

