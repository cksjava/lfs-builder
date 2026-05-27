#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / gcc-libstdc++
# Generated from book; do not edit — re-run generate_scripts.py
# gcc-libstdc++
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/gcc-libstdc++"
log_begin
trap 'log_fail $?' ERR

# Package: gcc-libstdc++
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gcc-15.2.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gcc-15.2.0"
log "Building in $(pwd)"

log_step 1 5 'mkdir -v build'
mkdir -v build
cd       build

log_step 2 5 '../libstdc++-v3/configure      \'
../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

log_step 3 5 'make'
make

log_step 4 5 'make'
make DESTDIR=$LFS install

log_step 5 5 'rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la'
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

trap - ERR
log_done

