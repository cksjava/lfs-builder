#!/bin/bash
# LFS 13.0-systemd — 07-system / iana-etc
# Generated from book; do not edit — re-run generate_scripts.py
# iana-etc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/iana-etc"
log_begin
trap 'log_fail $?' ERR

# Package: iana-etc
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "iana-etc-20260202" ]; then
  log "Removing prior iana-etc-20260202 tree"
  rm -rf "iana-etc-20260202"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 iana-etc-20260202*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "iana-etc-20260202" ]; then
  die "Source tarball not found matching iana-etc-20260202"
fi
if [ -n "$TARBALL" ] && [ ! -d "iana-etc-20260202" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "iana-etc-20260202" ] || die "Missing source directory iana-etc-20260202"
cd "iana-etc-20260202"
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

log_step 1 1 'cp -v services protocols /etc'
cp -v services protocols /etc

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree iana-etc-20260202"
rm -rf "iana-etc-20260202"

trap - ERR
log_done

