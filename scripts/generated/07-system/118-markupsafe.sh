#!/bin/bash
# LFS 13.0-systemd — 07-system / markupsafe
# Generated from book; do not edit — re-run generate_scripts.py
# markupsafe
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/markupsafe"
log_begin
trap 'log_fail $?' ERR

# Package: markupsafe
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "markupsafe-3.0.3" ]; then
  log "Removing prior markupsafe-3.0.3 tree"
  rm -rf "markupsafe-3.0.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 markupsafe-3.0.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "markupsafe-3.0.3" ]; then
  die "Source tarball not found matching markupsafe-3.0.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "markupsafe-3.0.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "markupsafe-3.0.3" ] || die "Missing source directory markupsafe-3.0.3"
cd "markupsafe-3.0.3"
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

log_step 2 2 'pip3 install --no-index --find-links dist Markupsafe'
pip3 install --no-index --find-links dist Markupsafe

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree markupsafe-3.0.3"
rm -rf "markupsafe-3.0.3"

trap - ERR
log_done

