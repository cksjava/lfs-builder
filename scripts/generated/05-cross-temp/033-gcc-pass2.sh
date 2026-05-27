#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / gcc-pass2
# Generated from book; do not edit — re-run generate_scripts.py
# gcc-pass2
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="05-cross-temp/gcc-pass2"
log_begin
trap 'log_fail $?' ERR

# Package: gcc-pass2
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gcc-15.2.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gcc-15.2.0"
log "Building in $(pwd)"

log_step 1 8 'extract source archive'
tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

log_step 2 8 'case $(uname -m) in'
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

log_step 3 8 'sed '"'"'/thread_header =/s/@.*@/gthr-posix.h/'"'"' \'
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

log_step 4 8 'mkdir -v build'
mkdir -v build
cd       build

log_step 5 8 'configure'
../configure                   \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --target=$LFS_TGT          \
    --prefix=/usr              \
    --with-build-sysroot=$LFS  \
    --enable-default-pie       \
    --enable-default-ssp       \
    --disable-nls              \
    --disable-multilib         \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libsanitizer     \
    --disable-libssp           \
    --disable-libvtv           \
    --enable-languages=c,c++   \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc

log_step 6 8 'make'
make

log_step 7 8 'make'
make DESTDIR=$LFS install

log_step 8 8 'ln -sv gcc $LFS/usr/bin/cc'
ln -sv gcc $LFS/usr/bin/cc

trap - ERR
log_done

