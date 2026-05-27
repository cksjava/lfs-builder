#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / gcc-libstdc++
# Generated from book; do not edit — re-run generate_scripts.py
# gcc-libstdc++
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gcc-libstdc++
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gcc-15.2.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gcc-15.2.0"

mkdir -v build
cd       build
../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
