#!/bin/bash
# LFS 13.0-systemd — 07-system / flit-core
# Generated from book; do not edit — re-run generate_scripts.py
# flit-core
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/flit-core"
log_begin
trap 'log_fail $?' ERR

# Package: flit-core
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "flit_core-3.12.0" ]; then
  log "Removing prior flit_core-3.12.0 tree"
  rm -rf "flit_core-3.12.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 flit_core-3.12.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "flit_core-3.12.0" ]; then
  die "Source tarball not found matching flit_core-3.12.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "flit_core-3.12.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "flit_core-3.12.0" ] || die "Missing source directory flit_core-3.12.0"
cd "flit_core-3.12.0"
log "Building in $(pwd)"

log_step 1 2 'pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

log_step 2 2 'pip3 install --no-index --find-links dist flit_core'
pip3 install --no-index --find-links dist flit_core

cd "${LFS_SOURCES:?}"
log "Removing source tree flit_core-3.12.0"
rm -rf "flit_core-3.12.0"

trap - ERR
log_done

