#!/bin/bash
# LFS 13.0-systemd — 07-system / libelf
# Generated from book; do not edit — re-run generate_scripts.py
# libelf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/libelf"
log_begin
trap 'log_fail $?' ERR

# Package: libelf
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "elfutils-0.194" ]; then
  log "Removing prior elfutils-0.194 tree"
  rm -rf "elfutils-0.194"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 elfutils-0.194*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "elfutils-0.194" ]; then
  die "Source tarball not found matching elfutils-0.194"
fi
if [ -n "$TARBALL" ] && [ ! -d "elfutils-0.194" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "elfutils-0.194" ] || die "Missing source directory elfutils-0.194"
cd "elfutils-0.194"
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

log_step 1 3 'configure'
./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

log_step 2 3 'make'
make -C lib
make -C libelf

log_step 3 3 'make'
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree elfutils-0.194"
rm -rf "elfutils-0.194"

trap - ERR
log_done

