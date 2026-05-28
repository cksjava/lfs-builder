#!/bin/bash
# LFS 13.0-systemd — 07-system / expat
# Generated from book; do not edit — re-run generate_scripts.py
# expat
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/expat"
log_begin
trap 'log_fail $?' ERR

# Package: expat
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "expat-2.7.4" ]; then
  log "Removing prior expat-2.7.4 tree"
  rm -rf "expat-2.7.4"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 expat-2.7.4*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "expat-2.7.4" ]; then
  die "Source tarball not found matching expat-2.7.4"
fi
if [ -n "$TARBALL" ] && [ ! -d "expat-2.7.4" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "expat-2.7.4" ] || die "Missing source directory expat-2.7.4"
cd "expat-2.7.4"
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
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.4

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

log_step 5 5 'install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.4'
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.4

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree expat-2.7.4"
rm -rf "expat-2.7.4"

trap - ERR
log_done

