#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / gawk
# Generated from book; do not edit — re-run generate_scripts.py
# gawk
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/gawk"
log_begin
trap 'log_fail $?' ERR

# Package: gawk
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gawk-5.3.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gawk-5.3.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gawk-5.3.2"
log "Building in $(pwd)"

log_step 1 4 'sed -i '"'"'s/extras//'"'"' Makefile.in'
sed -i 's/extras//' Makefile.in

log_step 2 4 'configure'
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

log_step 3 4 'make'
make

log_step 4 4 'make'
make DESTDIR=$LFS install

trap - ERR
log_done

