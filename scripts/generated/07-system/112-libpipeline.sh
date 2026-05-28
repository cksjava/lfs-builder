#!/bin/bash
# LFS 13.0-systemd — 07-system / libpipeline
# Generated from book; do not edit — re-run generate_scripts.py
# libpipeline
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/libpipeline"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: libpipeline
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "libpipeline-1.5.8" ]; then
  log "Removing prior libpipeline-1.5.8 tree"
  rm -rf "libpipeline-1.5.8"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 libpipeline-1.5.8*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "libpipeline-1.5.8" ]; then
  die "Source tarball not found matching libpipeline-1.5.8"
fi
if [ -n "$TARBALL" ] && [ ! -d "libpipeline-1.5.8" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "libpipeline-1.5.8" ] || die "Missing source directory libpipeline-1.5.8"
cd "libpipeline-1.5.8"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr

log_step 2 3 'make'
make

log_step 3 3 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree libpipeline-1.5.8"
rm -rf "libpipeline-1.5.8"

trap - ERR
log_done

