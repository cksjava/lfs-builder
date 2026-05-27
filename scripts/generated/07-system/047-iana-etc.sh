#!/bin/bash
# LFS 13.0-systemd — 07-system / iana-etc
# Generated from book; do not edit — re-run generate_scripts.py
# iana-etc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/iana-etc"
log_begin
trap 'log_fail $?' ERR

# Package: iana-etc
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 iana-etc-20260202*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "iana-etc-20260202" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "iana-etc-20260202"
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

log_step 1 1 'cp -v services protocols /etc'
cp -v services protocols /etc

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

