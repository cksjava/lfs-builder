#!/bin/bash
# LFS 13.0-systemd — 07-system / gzip
# Generated from book; do not edit — re-run generate_scripts.py
# gzip
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gzip"
log_begin
trap 'log_fail $?' ERR

# Package: gzip
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gzip-1.14" ]; then
  log "Removing prior gzip-1.14 tree"
  rm -rf "gzip-1.14"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gzip-1.14*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gzip-1.14" ]; then
  die "Source tarball not found matching gzip-1.14"
fi
if [ -n "$TARBALL" ] && [ ! -d "gzip-1.14" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gzip-1.14" ] || die "Missing source directory gzip-1.14"
cd "gzip-1.14"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr

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
log "Removing source tree gzip-1.14"
rm -rf "gzip-1.14"

trap - ERR
log_done

