#!/bin/bash
# LFS 13.0-systemd — 07-system / dbus
# Generated from book; do not edit — re-run generate_scripts.py
# dbus
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/dbus"
log_begin
trap 'log_fail $?' ERR

# Package: dbus
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 dbus-1.16.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "dbus-1.16.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "dbus-1.16.2"
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

log_step 1 6 'mkdir p build'
mkdir p build
cd    build

log_step 2 6 'meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..'
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..

log_step 3 6 'ninja'
ninja

log_step 4 6 'ninja test'
ninja test

log_step 5 6 'ninja install'
ninja install

log_step 6 6 'ln -sfv /etc/machine-id /var/lib/dbus'
ln -sfv /etc/machine-id /var/lib/dbus

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

