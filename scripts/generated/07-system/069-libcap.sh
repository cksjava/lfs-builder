#!/bin/bash
# LFS 13.0-systemd — 07-system / libcap
# Generated from book; do not edit — re-run generate_scripts.py
# libcap
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/libcap"
log_begin
trap 'log_fail $?' ERR

# Package: libcap
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "libcap-2.77" ]; then
  log "Removing prior libcap-2.77 tree"
  rm -rf "libcap-2.77"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 libcap-2.77*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "libcap-2.77" ]; then
  die "Source tarball not found matching libcap-2.77"
fi
if [ -n "$TARBALL" ] && [ ! -d "libcap-2.77" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "libcap-2.77" ] || die "Missing source directory libcap-2.77"
cd "libcap-2.77"
log "Building in $(pwd)"

log_step 1 4 'sed -i '"'"'/install -m.*STA/d'"'"' libcap/Makefile'
sed -i '/install -m.*STA/d' libcap/Makefile

log_step 2 4 'make'
make prefix=/usr lib=lib

log_step 3 4 'make'
make test

log_step 4 4 'make'
make prefix=/usr lib=lib install

cd "${LFS_SOURCES:?}"
log "Removing source tree libcap-2.77"
rm -rf "libcap-2.77"

trap - ERR
log_done

