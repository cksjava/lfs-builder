#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / xz
# Generated from book; do not edit — re-run generate_scripts.py
# xz
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: xz
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 xz-5.8.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "xz-5.8.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "xz-5.8.2"

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.2
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la
