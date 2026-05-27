#!/bin/bash
# LFS 13.0-systemd — 07-system / grep
# Generated from book; do not edit — re-run generate_scripts.py
# grep
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/grep"
log_begin
trap 'log_fail $?' ERR

# Package: grep
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 grep-3.12*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "grep-3.12" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "grep-3.12"
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

log_step 1 5 'sed -i "s/echo/#echo/" src/egrep.sh'
sed -i "s/echo/#echo/" src/egrep.sh

log_step 2 5 'configure'
./configure --prefix=/usr

log_step 3 5 'make'
make

log_step 4 5 'make check (test suite)'
make check

log_step 5 5 'make install'
make install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

