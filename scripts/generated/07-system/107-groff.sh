#!/bin/bash
# LFS 13.0-systemd — 07-system / groff
# Generated from book; do not edit — re-run generate_scripts.py
# groff
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/groff"
log_begin
trap 'log_fail $?' ERR

# Package: groff
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "groff-1.23.0" ]; then
  log "Removing prior groff-1.23.0 tree"
  rm -rf "groff-1.23.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 groff-1.23.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "groff-1.23.0" ]; then
  die "Source tarball not found matching groff-1.23.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "groff-1.23.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "groff-1.23.0" ] || die "Missing source directory groff-1.23.0"
cd "groff-1.23.0"
log "Building in $(pwd)"

log_step 1 4 'configure'
PAGE=<paper_size> ./configure --prefix=/usr

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
log "Removing source tree groff-1.23.0"
rm -rf "groff-1.23.0"

trap - ERR
log_done

