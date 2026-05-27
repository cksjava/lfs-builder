#!/bin/bash
# LFS 13.0-systemd — 07-system / gperf
# Generated from book; do not edit — re-run generate_scripts.py
# gperf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gperf"
log_begin
trap 'log_fail $?' ERR

# Package: gperf
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gperf-3.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gperf-3.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gperf-3.3"
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

log_step 1 4 'configure'
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

