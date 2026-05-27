#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / gettext
# Generated from book; do not edit — re-run generate_scripts.py
# gettext
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/gettext"
log_begin
trap 'log_fail $?' ERR

# Package: gettext
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gettext-1.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gettext-1.0"
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

log_step 1 3 'configure'
./configure --disable-shared

log_step 2 3 'make'
make

log_step 3 3 'cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin'
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

