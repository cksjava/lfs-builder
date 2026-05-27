#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / bash
# Generated from book; do not edit — re-run generate_scripts.py
# bash
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: bash
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 bash-5.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "bash-5.3" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "bash-5.3"

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc
make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
