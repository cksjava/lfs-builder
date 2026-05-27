#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / gzip
# Generated from book; do not edit — re-run generate_scripts.py
# gzip
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gzip
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gzip-1.14*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gzip-1.14" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gzip-1.14"

./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
