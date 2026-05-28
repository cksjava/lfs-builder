#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / diffutils
# Generated from book; do not edit — re-run generate_scripts.py
# diffutils
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/diffutils"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

# Package: diffutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "diffutils-3.12" ]; then
  log "Removing prior diffutils-3.12 tree"
  rm -rf "diffutils-3.12"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 diffutils-3.12*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "diffutils-3.12" ]; then
  die "Source tarball not found matching diffutils-3.12"
fi
if [ -n "$TARBALL" ] && [ ! -d "diffutils-3.12" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "diffutils-3.12" ] || die "Missing source directory diffutils-3.12"
cd "diffutils-3.12"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)

log_step 2 3 'make'
make

log_step 3 3 'make'
make DESTDIR=$LFS install

cd "${LFS_SOURCES:?}"
log "Removing source tree diffutils-3.12"
rm -rf "diffutils-3.12"

trap - ERR
log_done

