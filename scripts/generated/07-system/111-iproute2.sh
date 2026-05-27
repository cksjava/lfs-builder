#!/bin/bash
# LFS 13.0-systemd — 07-system / iproute2
# Generated from book; do not edit — re-run generate_scripts.py
# iproute2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/iproute2"
log_begin
trap 'log_fail $?' ERR

# Package: iproute2
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 iproute2-6.18.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "iproute2-6.18.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "iproute2-6.18.0"
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

log_step 1 4 'sed -i /ARPD/d Makefile'
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

log_step 2 4 'make'
make NETNS_RUN_DIR=/run/netns

log_step 3 4 'make'
make SBINDIR=/usr/sbin install

log_step 4 4 'install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.18.0'
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.18.0

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

