#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / m4
# Generated from book; do not edit — re-run generate_scripts.py
# m4
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/m4"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: m4
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "m4-1.4.21" ]; then
  log "Removing prior m4-1.4.21 tree"
  rm -rf "m4-1.4.21"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 m4-1.4.21*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "m4-1.4.21" ]; then
  die "Source tarball not found matching m4-1.4.21"
fi
if [ -n "$TARBALL" ] && [ ! -d "m4-1.4.21" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "m4-1.4.21" ] || die "Missing source directory m4-1.4.21"
cd "m4-1.4.21"
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
log "Removing source tree m4-1.4.21"
rm -rf "m4-1.4.21"

trap - ERR
log_done

