#!/bin/bash
# LFS 13.0-systemd — 07-system / tar
# Generated from book; do not edit — re-run generate_scripts.py
# tar
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/tar"
log_begin
trap 'log_fail $?' ERR

# Package: tar
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "tar-1.35" ]; then
  log "Removing prior tar-1.35 tree"
  rm -rf "tar-1.35"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 tar-1.35*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "tar-1.35" ]; then
  die "Source tarball not found matching tar-1.35"
fi
if [ -n "$TARBALL" ] && [ ! -d "tar-1.35" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "tar-1.35" ] || die "Missing source directory tar-1.35"
cd "tar-1.35"
log "Building in $(pwd)"

log_step 1 4 'configure'
FORCE_UNSAFE_CONFIGURE=1  \
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
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd "${LFS_SOURCES:?}"
log "Removing source tree tar-1.35"
rm -rf "tar-1.35"

trap - ERR
log_done

