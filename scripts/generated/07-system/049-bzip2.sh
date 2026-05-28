#!/bin/bash
# LFS 13.0-systemd — 07-system / bzip2
# Generated from book; do not edit — re-run generate_scripts.py
# bzip2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/bzip2"
log_begin
trap 'log_fail $?' ERR

# Package: bzip2
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "bzip2-1.0.8" ]; then
  log "Removing prior bzip2-1.0.8 tree"
  rm -rf "bzip2-1.0.8"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 bzip2-1.0.8*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "bzip2-1.0.8" ]; then
  die "Source tarball not found matching bzip2-1.0.8"
fi
if [ -n "$TARBALL" ] && [ ! -d "bzip2-1.0.8" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "bzip2-1.0.8" ] || die "Missing source directory bzip2-1.0.8"
cd "bzip2-1.0.8"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 10 'apply patch'
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

log_step 2 10 'sed -i '"'"'s@\(ln -s -f \)$(PREFIX)/bin/@\1@'"'"' Makefile'
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

log_step 3 10 'sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile'
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

log_step 4 10 'make'
make -f Makefile-libbz2_so
make clean

log_step 5 10 'make'
make

log_step 6 10 'make'
make PREFIX=/usr install

log_step 7 10 'cp -av libbz2.so.* /usr/lib'
cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so

log_step 8 10 'ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1'
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1

log_step 9 10 'cp -v bzip2-shared /usr/bin/bzip2'
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

log_step 10 10 'rm -fv /usr/lib/libbz2.a'
rm -fv /usr/lib/libbz2.a

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree bzip2-1.0.8"
rm -rf "bzip2-1.0.8"

trap - ERR
log_done

