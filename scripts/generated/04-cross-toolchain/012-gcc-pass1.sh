#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / gcc-pass1
# Generated from book; do not edit — re-run generate_scripts.py
# gcc-pass1
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/gcc-pass1"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

# Package: gcc-pass1
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gcc-15.2.0" ]; then
  log "Removing prior gcc-15.2.0 tree"
  rm -rf "gcc-15.2.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gcc-15.2.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  die "Source tarball not found matching gcc-15.2.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gcc-15.2.0" ] || die "Missing source directory gcc-15.2.0"
cd "gcc-15.2.0"
log "Building in $(pwd)"

log_step 1 7 'extract source archive'
tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

log_step 2 7 'case $(uname -m) in'
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

log_step 3 7 'mkdir -vp build'
mkdir -vp build
cd       build

log_step 4 7 'configure'
../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.43 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

log_step 5 7 'make'
make

log_step 6 7 'make install'
make install

log_step 7 7 'cd ..'
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h

cd "${LFS_SOURCES:?}"
log "Removing source tree gcc-15.2.0"
rm -rf "gcc-15.2.0"

trap - ERR
log_done

