#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / binutils-pass1
# Generated from book; do not edit — re-run generate_scripts.py
# binutils-pass1
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: binutils-pass1
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 binutils-2.46.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "binutils-2.46.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "binutils-2.46.0"

mkdir -v build
cd       build
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu
make
make install
