#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / linux-headers
# Generated from book; do not edit — re-run generate_scripts.py
# linux-headers
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="04-cross-toolchain/linux-headers"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: linux-headers
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 linux-6.18.10*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "linux-6.18.10" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "linux-6.18.10"
log "Building in $(pwd)"

log_step 1 2 'make'
make mrproper

log_step 2 2 'make'
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

trap - ERR
log_done

