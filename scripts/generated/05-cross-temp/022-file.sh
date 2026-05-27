#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / file
# Generated from book; do not edit — re-run generate_scripts.py
# file
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: file
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 file-5.46*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "file-5.46"

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la
