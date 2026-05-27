#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / gawk
# Generated from book; do not edit — re-run generate_scripts.py
# gawk
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gawk
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gawk-5.3.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gawk-5.3.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gawk-5.3.2"

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
