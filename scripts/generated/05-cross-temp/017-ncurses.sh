#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / ncurses
# Generated from book; do not edit — re-run generate_scripts.py
# ncurses
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/ncurses"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: ncurses
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 ncurses-6.6*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "ncurses-6.6" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "ncurses-6.6"
log "Building in $(pwd)"

log_step 1 4 'configure'
mkdir p build
pushd build
  ../configure --prefix=$LFS/tools AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic $LFS/tools/bin
popd

log_step 2 4 'configure'
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

log_step 3 4 'make'
make

log_step 4 4 'make'
make DESTDIR=$LFS install
ln -svf libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

trap - ERR
log_done

