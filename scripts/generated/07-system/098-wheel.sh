#!/bin/bash
# LFS 13.0-systemd — 07-system / wheel
# Generated from book; do not edit — re-run generate_scripts.py
# wheel
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/wheel"
log_begin
trap 'log_fail $?' ERR

# Package: wheel
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "wheel-0.46.3" ]; then
  log "Removing prior wheel-0.46.3 tree"
  rm -rf "wheel-0.46.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 wheel-0.46.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "wheel-0.46.3" ]; then
  die "Source tarball not found matching wheel-0.46.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "wheel-0.46.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "wheel-0.46.3" ] || die "Missing source directory wheel-0.46.3"
cd "wheel-0.46.3"
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

log_step 2 2 'pip3 install --no-index --find-links dist wheel'
pip3 install --no-index --find-links dist wheel

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree wheel-0.46.3"
rm -rf "wheel-0.46.3"

trap - ERR
log_done

