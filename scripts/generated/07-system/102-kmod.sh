#!/bin/bash
# LFS 13.0-systemd — 07-system / kmod
# Generated from book; do not edit — re-run generate_scripts.py
# kmod
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/kmod"
log_begin
trap 'log_fail $?' ERR

# Package: kmod
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "kmod-34.2" ]; then
  log "Removing prior kmod-34.2 tree"
  rm -rf "kmod-34.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 kmod-34.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "kmod-34.2" ]; then
  die "Source tarball not found matching kmod-34.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "kmod-34.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "kmod-34.2" ] || die "Missing source directory kmod-34.2"
cd "kmod-34.2"
log "Building in $(pwd)"

log_step 1 4 'mkdir -p build'
mkdir -p build
cd       build

log_step 2 4 'meson setup --prefix=/usr ..    \'
meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false

log_step 3 4 'ninja'
ninja

log_step 4 4 'ninja install'
ninja install

cd "${LFS_SOURCES:?}"
log "Removing source tree kmod-34.2"
rm -rf "kmod-34.2"

trap - ERR
log_done

