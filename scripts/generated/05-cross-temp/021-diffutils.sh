#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / diffutils
# Generated from book; do not edit — re-run generate_scripts.py
# diffutils
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: diffutils
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 diffutils-3.12*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "diffutils-3.12" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "diffutils-3.12"

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install
