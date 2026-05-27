#!/bin/bash
# LFS 13.0-systemd — 07-system / binutils
# Generated from book; do not edit — re-run generate_scripts.py
# binutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/binutils"
log_begin
trap 'log_fail $?' ERR

# Package: binutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 binutils-2.46.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "binutils-2.46.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "binutils-2.46.0"
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

log_step 1 7 'mkdir -v build'
mkdir -v build
cd       build

log_step 2 7 'configure'
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

log_step 3 7 'make'
make tooldir=/usr

log_step 4 7 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make -k check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 7 'grep '"'"'^FAIL:'"'"' $(find -name '"'"'*.log'"'"')'
grep '^FAIL:' $(find -name '*.log')

log_step 6 7 'make'
make tooldir=/usr install

log_step 7 7 'rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \'
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

