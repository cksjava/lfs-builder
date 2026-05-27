#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / gcc-pass1
# Generated from book; do not edit — re-run generate_scripts.py
# gcc-pass1
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gcc-pass1
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gcc-15.2.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gcc-15.2.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gcc-15.2.0"

tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac
mkdir -v build
cd       build
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
make
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
