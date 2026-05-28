#!/bin/bash
# LFS 13.0-systemd — 07-system / findutils
# Generated from book; do not edit — re-run generate_scripts.py
# findutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/findutils"
log_begin
trap 'log_fail $?' ERR

# Package: findutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "findutils-4.10.0" ]; then
  log "Removing prior findutils-4.10.0 tree"
  rm -rf "findutils-4.10.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 findutils-4.10.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "findutils-4.10.0" ]; then
  die "Source tarball not found matching findutils-4.10.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "findutils-4.10.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "findutils-4.10.0" ] || die "Missing source directory findutils-4.10.0"
cd "findutils-4.10.0"
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
./configure --prefix=/usr --localstatedir=/var/lib/locate

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  chown -R tester .
  su tester -c "PATH=$PATH make check"
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree findutils-4.10.0"
rm -rf "findutils-4.10.0"

trap - ERR
log_done

