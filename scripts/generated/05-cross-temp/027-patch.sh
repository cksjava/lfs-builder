#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / patch
# Generated from book; do not edit — re-run generate_scripts.py
# patch
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/patch"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: patch
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "patch-2.8" ]; then
  log "Removing prior patch-2.8 tree"
  rm -rf "patch-2.8"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 patch-2.8*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "patch-2.8" ]; then
  die "Source tarball not found matching patch-2.8"
fi
if [ -n "$TARBALL" ] && [ ! -d "patch-2.8" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "patch-2.8" ] || die "Missing source directory patch-2.8"
cd "patch-2.8"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

log_step 2 3 'make'
make

log_step 3 3 'make'
make DESTDIR=$LFS install

cd "${LFS_SOURCES:?}"
log "Removing source tree patch-2.8"
rm -rf "patch-2.8"

trap - ERR
log_done

