#!/bin/bash
# LFS 13.0-systemd — 07-system / libtool
# Generated from book; do not edit — re-run generate_scripts.py
# libtool
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/libtool"
log_begin
trap 'log_fail $?' ERR

# Package: libtool
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "libtool-2.5.4" ]; then
  log "Removing prior libtool-2.5.4 tree"
  rm -rf "libtool-2.5.4"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 libtool-2.5.4*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "libtool-2.5.4" ]; then
  die "Source tarball not found matching libtool-2.5.4"
fi
if [ -n "$TARBALL" ] && [ ! -d "libtool-2.5.4" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "libtool-2.5.4" ] || die "Missing source directory libtool-2.5.4"
cd "libtool-2.5.4"
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

log_step 1 5 'configure'
./configure --prefix=/usr

log_step 2 5 'make'
make

log_step 3 5 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 5 'make install'
make install

log_step 5 5 'rm -fv /usr/lib/libltdl.a'
rm -fv /usr/lib/libltdl.a

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree libtool-2.5.4"
rm -rf "libtool-2.5.4"

trap - ERR
log_done

