#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / grep
# Generated from book; do not edit — re-run generate_scripts.py
# grep
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: grep
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 grep-3.12*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "grep-3.12" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "grep-3.12"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install
