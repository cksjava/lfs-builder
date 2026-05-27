#!/bin/bash
# LFS 13.0-systemd — 07-system / intltool
# Generated from book; do not edit — re-run generate_scripts.py
# intltool
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/intltool"
log_begin
trap 'log_fail $?' ERR

# Package: intltool
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 intltool-0.51.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "intltool-0.51.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "intltool-0.51.0"
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

log_step 1 5 'sed -i '"'"'s:\\\${:\\\$\\{:'"'"' intltool-update.in'
sed -i 's:\\\${:\\\$\\{:' intltool-update.in

log_step 2 5 'configure'
./configure --prefix=/usr

log_step 3 5 'make'
make

log_step 4 5 'make check (test suite)'
make check

log_step 5 5 'make install'
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

