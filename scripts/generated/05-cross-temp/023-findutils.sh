#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / findutils
# Generated from book; do not edit — re-run generate_scripts.py
# findutils
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: findutils
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 findutils-4.10.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "findutils-4.10.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "findutils-4.10.0"

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
