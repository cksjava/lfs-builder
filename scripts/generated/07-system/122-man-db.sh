#!/bin/bash
# LFS 13.0-systemd — 07-system / man-db
# Generated from book; do not edit — re-run generate_scripts.py
# man-db
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/man-db"
log_begin
trap 'log_fail $?' ERR

# Package: man-db
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "man-db-2.13.1" ]; then
  log "Removing prior man-db-2.13.1 tree"
  rm -rf "man-db-2.13.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 man-db-2.13.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "man-db-2.13.1" ]; then
  die "Source tarball not found matching man-db-2.13.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "man-db-2.13.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "man-db-2.13.1" ] || die "Missing source directory man-db-2.13.1"
cd "man-db-2.13.1"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap

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

cd "${LFS_SOURCES:?}"
log "Removing source tree man-db-2.13.1"
rm -rf "man-db-2.13.1"

trap - ERR
log_done

