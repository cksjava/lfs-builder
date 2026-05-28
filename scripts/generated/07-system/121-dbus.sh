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
if [ -d "dbus-1.16.2" ]; then
  log "Removing prior dbus-1.16.2 tree"
  rm -rf "dbus-1.16.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 dbus-1.16.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "dbus-1.16.2" ]; then
  die "Source tarball not found matching dbus-1.16.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "dbus-1.16.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "dbus-1.16.2" ] || die "Missing source directory dbus-1.16.2"
cd "dbus-1.16.2"
log "Building in $(pwd)"

log_step 1 6 'mkdir p build'
mkdir p build
cd    build

log_step 2 6 'meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..'
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..

log_step 3 6 'ninja'
ninja

log_step 4 6 'if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  ninja test
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 6 'ninja install'
ninja install

log_step 6 6 'ln -sfv /etc/machine-id /var/lib/dbus'
ln -sfv /etc/machine-id /var/lib/dbus

cd "${LFS_SOURCES:?}"
log "Removing source tree dbus-1.16.2"
rm -rf "dbus-1.16.2"

trap - ERR
log_done

