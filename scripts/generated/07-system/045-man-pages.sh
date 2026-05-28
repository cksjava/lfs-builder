#!/bin/bash
# LFS 13.0-systemd — 07-system / man-pages
# Generated from book; do not edit — re-run generate_scripts.py
# man-pages
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/man-pages"
log_begin
trap 'log_fail $?' ERR

# Package: man-pages
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "man-pages-6.17" ]; then
  log "Removing prior man-pages-6.17 tree"
  rm -rf "man-pages-6.17"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 man-pages-6.17*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "man-pages-6.17" ]; then
  die "Source tarball not found matching man-pages-6.17"
fi
if [ -n "$TARBALL" ] && [ ! -d "man-pages-6.17" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "man-pages-6.17" ] || die "Missing source directory man-pages-6.17"
cd "man-pages-6.17"
log "Building in $(pwd)"

log_step 1 2 'rm -v man3/crypt*'
rm -v man3/crypt*

log_step 2 2 'make'
make -R GIT=false prefix=/usr install

cd "${LFS_SOURCES:?}"
log "Removing source tree man-pages-6.17"
rm -rf "man-pages-6.17"

trap - ERR
log_done

