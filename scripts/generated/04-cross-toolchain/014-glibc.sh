#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / glibc
# Generated from book; do not edit — re-run generate_scripts.py
# glibc
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/glibc"
log_begin
trap 'log_fail $?' ERR

# Package: glibc
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 glibc-2.43*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "glibc-2.43" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "glibc-2.43"
log "Building in $(pwd)"

log_step 1 15 'case $(uname -m) in'
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac

log_step 2 15 'apply patch'
patch -Np1 -i ../glibc-fhs-1.patch

log_step 3 15 'mkdir -v build'
mkdir -v build
cd       build

log_step 4 15 'echo "rootsbindir=/usr/sbin" > configparms'
echo "rootsbindir=/usr/sbin" > configparms

log_step 5 15 'configure'
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4

log_step 6 15 'make'
make

log_step 7 15 'make'
make DESTDIR=$LFS install

log_step 8 15 'sed '"'"'/RTLDLIST=/s@/usr@@g'"'"' -i $LFS/usr/bin/ldd'
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

log_step 9 15 'echo '"'"'int main(){}'"'"' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log'
echo 'int main(){}' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

log_step 10 15 'grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log'
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log

log_step 11 15 'grep -B3 "^ $LFS/usr/include" dummy.log'
grep -B3 "^ $LFS/usr/include" dummy.log

log_step 12 15 'grep '"'"'SEARCH.*/usr/lib'"'"' dummy.log |sed '"'"'s|; |\n|g'"'"''
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

log_step 13 15 'grep "/lib.*/libc.so.6 " dummy.log'
grep "/lib.*/libc.so.6 " dummy.log

log_step 14 15 'grep found dummy.log'
grep found dummy.log

log_step 15 15 'rm -v a.out dummy.log'
rm -v a.out dummy.log

trap - ERR
log_done

