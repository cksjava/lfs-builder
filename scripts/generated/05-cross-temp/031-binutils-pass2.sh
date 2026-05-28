#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / binutils-pass2
# Generated from book; do not edit — re-run generate_scripts.py
# binutils-pass2
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/binutils-pass2"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: binutils-pass2
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

log_step 1 6 'sed '"'"'6031s/$add_dir//'"'"' -i ltmain.sh'
sed '6031s/$add_dir//' -i ltmain.sh

log_step 2 6 'mkdir -vp build'
mkdir -vp build
cd       build

log_step 3 6 'configure'
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu

log_step 4 6 'make'
make

log_step 5 6 'make'
make DESTDIR=$LFS install

log_step 6 6 'rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}'
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

trap - ERR
log_done

