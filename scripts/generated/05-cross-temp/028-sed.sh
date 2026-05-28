#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/sed"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: sed
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "sed-4.9" ]; then
  log "Removing prior sed-4.9 tree"
  rm -rf "sed-4.9"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  die "Source tarball not found matching sed-4.9"
fi
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "sed-4.9" ] || die "Missing source directory sed-4.9"
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

cd "${LFS_SOURCES:?}"
log "Removing source tree sed-4.9"
rm -rf "sed-4.9"

trap - ERR
log_done

