#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / make
# Generated from book; do not edit — re-run generate_scripts.py
# make
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/make"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

# Package: make
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "make-4.4.1" ]; then
  log "Removing prior make-4.4.1 tree"
  rm -rf "make-4.4.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 make-4.4.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "make-4.4.1" ]; then
  die "Source tarball not found matching make-4.4.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "make-4.4.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "make-4.4.1" ] || die "Missing source directory make-4.4.1"
cd "make-4.4.1"
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
log "Removing source tree make-4.4.1"
rm -rf "make-4.4.1"

trap - ERR
log_done

