#!/bin/bash
# LFS 13.0-systemd — 07-system / patch
# Generated from book; do not edit — re-run generate_scripts.py
# patch
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/patch"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: patch
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "patch-2.8" ]; then
  log "Removing prior patch-2.8 tree"
  rm -rf "patch-2.8"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 patch-2.8*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "patch-2.8" ]; then
  die "Source tarball not found matching patch-2.8"
fi
if [ -n "$TARBALL" ] && [ ! -d "patch-2.8" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "patch-2.8" ] || die "Missing source directory patch-2.8"
cd "patch-2.8"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree patch-2.8"
rm -rf "patch-2.8"

trap - ERR
log_done

