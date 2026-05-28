#!/bin/bash
# LFS 13.0-systemd — 07-system / lz4
# Generated from book; do not edit — re-run generate_scripts.py
# lz4
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/lz4"
log_begin
trap 'log_fail $?' ERR

# Package: lz4
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "lz4-1.10.0" ]; then
  log "Removing prior lz4-1.10.0 tree"
  rm -rf "lz4-1.10.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 lz4-1.10.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "lz4-1.10.0" ]; then
  die "Source tarball not found matching lz4-1.10.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "lz4-1.10.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "lz4-1.10.0" ] || die "Missing source directory lz4-1.10.0"
cd "lz4-1.10.0"
log "Building in $(pwd)"

log_step 1 3 'make'
make BUILD_STATIC=no PREFIX=/usr

log_step 2 3 'make'
make -j1 check

log_step 3 3 'make'
make BUILD_STATIC=no PREFIX=/usr install

cd "${LFS_SOURCES:?}"
log "Removing source tree lz4-1.10.0"
rm -rf "lz4-1.10.0"

trap - ERR
log_done

