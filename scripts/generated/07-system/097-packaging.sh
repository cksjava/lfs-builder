#!/bin/bash
# LFS 13.0-systemd — 07-system / packaging
# Generated from book; do not edit — re-run generate_scripts.py
# packaging
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/packaging"
log_begin
trap 'log_fail $?' ERR

# Package: packaging
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "packaging-26.0" ]; then
  log "Removing prior packaging-26.0 tree"
  rm -rf "packaging-26.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 packaging-26.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "packaging-26.0" ]; then
  die "Source tarball not found matching packaging-26.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "packaging-26.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "packaging-26.0" ] || die "Missing source directory packaging-26.0"
cd "packaging-26.0"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 2 'pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

log_step 2 2 'pip3 install --no-index --find-links dist packaging'
pip3 install --no-index --find-links dist packaging

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree packaging-26.0"
rm -rf "packaging-26.0"

trap - ERR
log_done

