#!/bin/bash
# LFS 13.0-systemd — 07-system / libxcrypt
# Generated from book; do not edit — re-run generate_scripts.py
# libxcrypt
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/libxcrypt"
log_begin
trap 'log_fail $?' ERR

# Package: libxcrypt
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 libxcrypt-4.5.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "libxcrypt-4.5.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "libxcrypt-4.5.2"
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

log_step 1 6 'sed -i '"'"'/strchr/s/const//'"'"' lib/crypt-{sm3,gost}-yescrypt.c'
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c

log_step 2 6 'configure'
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

log_step 3 6 'make'
make

log_step 4 6 'make check (test suite)'
make check

log_step 5 6 'make install'
make install

log_step 6 6 'configure'
make distclean
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=glibc  \
            --disable-static             \
            --disable-failure-tokens
make
cp -av --remove-destination .libs/libcrypt.so.1* /usr/lib

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

