#!/bin/bash
# LFS 13.0-systemd — 07-system / pkgconf
# Generated from book; do not edit — re-run generate_scripts.py
# pkgconf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/pkgconf"
log_begin
trap 'log_fail $?' ERR

# Package: pkgconf
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "pkgconf-2.5.1" ]; then
  log "Removing prior pkgconf-2.5.1 tree"
  rm -rf "pkgconf-2.5.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 pkgconf-2.5.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "pkgconf-2.5.1" ]; then
  die "Source tarball not found matching pkgconf-2.5.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "pkgconf-2.5.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "pkgconf-2.5.1" ] || die "Missing source directory pkgconf-2.5.1"
cd "pkgconf-2.5.1"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

log_step 2 4 'make'
make

log_step 3 4 'make install'
make install

log_step 4 4 'ln -svf pkgconf   /usr/bin/pkg-config'
ln -svf pkgconf   /usr/bin/pkg-config
ln -svf pkgconf.1 /usr/share/man/man1/pkg-config.1

cd "${LFS_SOURCES:?}"
log "Removing source tree pkgconf-2.5.1"
rm -rf "pkgconf-2.5.1"

trap - ERR
log_done

