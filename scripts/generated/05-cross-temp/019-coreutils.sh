#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / coreutils
# Generated from book; do not edit — re-run generate_scripts.py
# coreutils
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/coreutils"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: coreutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "coreutils-9.10" ]; then
  log "Removing prior coreutils-9.10 tree"
  rm -rf "coreutils-9.10"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 coreutils-9.10*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "coreutils-9.10" ]; then
  die "Source tarball not found matching coreutils-9.10"
fi
if [ -n "$TARBALL" ] && [ ! -d "coreutils-9.10" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "coreutils-9.10" ] || die "Missing source directory coreutils-9.10"
cd "coreutils-9.10"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

log_step 2 4 'make'
make

log_step 3 4 'make'
make DESTDIR=$LFS install

log_step 4 4 'mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin'
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd "${LFS_SOURCES:?}"
log "Removing source tree coreutils-9.10"
rm -rf "coreutils-9.10"

trap - ERR
log_done

