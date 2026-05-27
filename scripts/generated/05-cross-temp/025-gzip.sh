#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / gzip
# Generated from book; do not edit — re-run generate_scripts.py
# gzip
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/gzip"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: gzip
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gzip-1.14*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gzip-1.14" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gzip-1.14"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr --host=$LFS_TGT

log_step 2 3 'make'
make

log_step 3 3 'make'
make DESTDIR=$LFS install

trap - ERR
log_done

