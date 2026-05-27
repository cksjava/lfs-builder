#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / tar
# Generated from book; do not edit — re-run generate_scripts.py
# tar
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: tar
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 tar-1.35*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "tar-1.35" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "tar-1.35"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
