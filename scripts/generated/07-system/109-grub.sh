#!/bin/bash
# LFS 13.0-systemd — 07-system / grub
# Generated from book; do not edit — re-run generate_scripts.py
# grub
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/grub"
log_begin
trap 'log_fail $?' ERR

# Package: grub
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 grub-2.14*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "grub-2.14" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "grub-2.14"
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

log_step 1 5 'unset {C,CPP,CXX,LD}FLAGS'
unset {C,CPP,CXX,LD}FLAGS

log_step 2 5 'sed '"'"'s/--image-base/--nonexist-linker-option/'"'"' -i configure'
sed 's/--image-base/--nonexist-linker-option/' -i configure

log_step 3 5 'configure'
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

log_step 4 5 'make'
make

log_step 5 5 'make install'
make install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

