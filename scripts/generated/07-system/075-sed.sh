#!/bin/bash
# LFS 13.0-systemd — 07-system / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/sed"
log_begin
trap 'log_fail $?' ERR

# Package: sed
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "sed-4.9"
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
./configure --prefix=/usr

log_step 2 4 'make'
make
make html

log_step 3 4 'make check (test suite)'
chown -R tester .
su tester -c "PATH=$PATH make check"

log_step 4 4 'make install'
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

