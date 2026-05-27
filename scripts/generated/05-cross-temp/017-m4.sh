#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / m4
# Generated from book; do not edit — re-run generate_scripts.py
# m4
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: m4
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 m4-1.4.21*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "m4-1.4.21" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "m4-1.4.21"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
