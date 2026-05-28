#!/bin/bash
# LFS 13.0-systemd — 07-system / attr
# Generated from book; do not edit — re-run generate_scripts.py
# attr
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/attr"
log_begin
trap 'log_fail $?' ERR

# Package: attr
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "attr-2.5.2" ]; then
  log "Removing prior attr-2.5.2 tree"
  rm -rf "attr-2.5.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 attr-2.5.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "attr-2.5.2" ]; then
  die "Source tarball not found matching attr-2.5.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "attr-2.5.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "attr-2.5.2" ] || die "Missing source directory attr-2.5.2"
cd "attr-2.5.2"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

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
log "Removing source tree attr-2.5.2"
rm -rf "attr-2.5.2"

trap - ERR
log_done

