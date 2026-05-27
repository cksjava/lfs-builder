#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / patch
# Generated from book; do not edit — re-run generate_scripts.py
# patch
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: patch
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 patch-2.8*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "patch-2.8" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "patch-2.8"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
