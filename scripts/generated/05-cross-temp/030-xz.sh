#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / xz
# Generated from book; do not edit — re-run generate_scripts.py
# xz
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/xz"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: xz
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 xz-5.8.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "xz-5.8.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "xz-5.8.2"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.2

log_step 2 4 'make'
make

log_step 3 4 'make'
make DESTDIR=$LFS install

log_step 4 4 'rm -v $LFS/usr/lib/liblzma.la'
rm -v $LFS/usr/lib/liblzma.la

trap - ERR
log_done

