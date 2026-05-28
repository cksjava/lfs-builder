#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / findutils
# Generated from book; do not edit — re-run generate_scripts.py
# findutils
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/findutils"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: findutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "findutils-4.10.0" ]; then
  log "Removing prior findutils-4.10.0 tree"
  rm -rf "findutils-4.10.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 findutils-4.10.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "findutils-4.10.0" ]; then
  die "Source tarball not found matching findutils-4.10.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "findutils-4.10.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "findutils-4.10.0" ] || die "Missing source directory findutils-4.10.0"
cd "findutils-4.10.0"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

log_step 2 3 'make'
make

log_step 3 3 'make'
make DESTDIR=$LFS install

cd "${LFS_SOURCES:?}"
log "Removing source tree findutils-4.10.0"
rm -rf "findutils-4.10.0"

trap - ERR
log_done

