#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / bash
# Generated from book; do not edit — re-run generate_scripts.py
# bash
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/bash"
log_begin
trap 'log_fail $?' ERR

require_var LFS

# Package: bash
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 bash-5.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "bash-5.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "bash-5.3"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

log_step 2 4 'make'
make

log_step 3 4 'make'
make DESTDIR=$LFS install

log_step 4 4 'ln -svf bash $LFS/bin/sh'
ln -svf bash $LFS/bin/sh

trap - ERR
log_done

