#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / ncurses
# Generated from book; do not edit — re-run generate_scripts.py
# ncurses
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: ncurses
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 ncurses-6.6*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "ncurses-6.6" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "ncurses-6.6"

mkdir build
pushd build
  ../configure --prefix=$LFS/tools AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic $LFS/tools/bin
popd
./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk
make
make DESTDIR=$LFS install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h
