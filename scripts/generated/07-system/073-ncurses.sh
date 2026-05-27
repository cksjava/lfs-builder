#!/bin/bash
# LFS 13.0-systemd — 07-system / ncurses
# Generated from book; do not edit — re-run generate_scripts.py
# ncurses
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/ncurses"
log_begin
trap 'log_fail $?' ERR

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

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 7 'configure'
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

log_step 2 7 'make'
make

log_step 3 7 'make'
make DESTDIR=$PWD/dest install
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp --remove-destination -av dest/* /

log_step 4 7 'for lib in ncurses form panel menu ; do'
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

log_step 5 7 'ln -sfv libncursesw.so /usr/lib/libcurses.so'
ln -sfv libncursesw.so /usr/lib/libcurses.so

log_step 6 7 'cp -v -R doc -T /usr/share/doc/ncurses-6.6'
cp -v -R doc -T /usr/share/doc/ncurses-6.6

log_step 7 7 'configure'
make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding \
            --with-abi-version=5
make sources libs
cp -av lib/lib*.so.5* /usr/lib

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

