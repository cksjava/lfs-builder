#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="05-cross-temp/sed"
log_begin
trap 'log_fail $?' ERR

# Package: sed
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "sed-4.9"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

log_step 2 3 'make'
make

log_step 3 3 'make'
make DESTDIR=$LFS install

trap - ERR
log_done

