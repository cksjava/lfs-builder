#!/bin/bash
# LFS 13.0-systemd — 07-system / setuptools
# Generated from book; do not edit — re-run generate_scripts.py
# setuptools
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/setuptools"
log_begin
trap 'log_fail $?' ERR

# Package: setuptools
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 setuptools-82.0.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "setuptools-82.0.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "setuptools-82.0.0"
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

log_step 1 2 'pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

log_step 2 2 'pip3 install --no-index --find-links dist setuptools'
pip3 install --no-index --find-links dist setuptools

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

