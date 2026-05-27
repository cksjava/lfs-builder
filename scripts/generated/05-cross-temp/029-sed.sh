#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: sed
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "sed-4.9"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install
