#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / binutils-pass1
# Generated from book; do not edit — re-run generate_scripts.py
# binutils-pass1
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/binutils-pass1"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: binutils-pass1
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 binutils-2.46.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "binutils-2.46.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "binutils-2.46.0"
log "Building in $(pwd)"

log_step 1 4 'mkdir -vp build'
mkdir -vp build
cd       build

log_step 2 4 'configure'
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

log_step 3 4 'make'
make

log_step 4 4 'make install'
make install

trap - ERR
log_done

