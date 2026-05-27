#!/bin/bash
# LFS 13.0-systemd — 07-system / flex
# Generated from book; do not edit — re-run generate_scripts.py
# flex
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/flex"
log_begin
trap 'log_fail $?' ERR

# Package: flex
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 flex-2.6.4*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "flex-2.6.4" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "flex-2.6.4"
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

log_step 1 5 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4

log_step 2 5 'make'
make

log_step 3 5 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 5 'make install'
make install

log_step 5 5 'ln -svf flex   /usr/bin/lex'
ln -svf flex   /usr/bin/lex
ln -svf flex.1 /usr/share/man/man1/lex.1

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

