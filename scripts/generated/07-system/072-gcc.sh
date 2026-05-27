#!/bin/bash
# LFS 13.0-systemd — 07-system / gcc
# Generated from book; do not edit — re-run generate_scripts.py
# gcc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gcc"
log_begin
trap 'log_fail $?' ERR

# Package: gcc
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

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 22 'sed -i '"'"'s/char [*]q/const &/'"'"' libgomp/affinity-fmt.c'
sed -i 's/char [*]q/const &/' libgomp/affinity-fmt.c

log_step 2 22 'case $(uname -m) in'
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

log_step 3 22 'mkdir -v build'
mkdir -v build
cd       build

log_step 4 22 'configure'
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

log_step 5 22 'make'
make

log_step 6 22 'ulimit -s -H unlimited'
ulimit -s -H unlimited

log_step 7 22 'sed -e '"'"'/cpython/d'"'"' -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp'
sed -e '/cpython/d' -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp

log_step 8 22 'make check (test suite)'
chown -R tester .
su tester -c "PATH=$PATH make -k check"

log_step 9 22 '../contrib/test_summary'
../contrib/test_summary

log_step 10 22 'make install'
make install

log_step 11 22 'chown -v -R root:root \'
chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/15.2.0/include{,-fixed}

log_step 12 22 'ln -sfvr /usr/bin/cpp /usr/lib'
ln -sfvr /usr/bin/cpp /usr/lib

log_step 13 22 'ln -svf gcc.1 /usr/share/man/man1/cc.1'
ln -svf gcc.1 /usr/share/man/man1/cc.1

log_step 14 22 'ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \'
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

log_step 15 22 'echo '"'"'int main(){}'"'"' | cc -x c - -v -Wl,--verbose &> dummy.log'
echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

log_step 16 22 'grep -E -o '"'"'/usr/lib.*/S?crt[1in].*succeeded'"'"' dummy.log'
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log

log_step 17 22 'grep -B4 '"'"'^ /usr/include'"'"' dummy.log'
grep -B4 '^ /usr/include' dummy.log

log_step 18 22 'grep '"'"'SEARCH.*/usr/lib'"'"' dummy.log |sed '"'"'s|; |\n|g'"'"''
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

log_step 19 22 'grep "/lib.*/libc.so.6 " dummy.log'
grep "/lib.*/libc.so.6 " dummy.log

log_step 20 22 'grep found dummy.log'
grep found dummy.log

log_step 21 22 'rm -v a.out dummy.log'
rm -v a.out dummy.log

log_step 22 22 'mkdir -pv /usr/share/gdb/auto-load/usr/lib'
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

