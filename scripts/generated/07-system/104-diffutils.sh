#!/bin/bash
# LFS 13.0-systemd — 07-system / diffutils
# Generated from book; do not edit — re-run generate_scripts.py
# diffutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/diffutils"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: diffutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "diffutils-3.12" ]; then
  log "Removing prior diffutils-3.12 tree"
  rm -rf "diffutils-3.12"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 diffutils-3.12*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "diffutils-3.12" ]; then
  die "Source tarball not found matching diffutils-3.12"
fi
if [ -n "$TARBALL" ] && [ ! -d "diffutils-3.12" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "diffutils-3.12" ] || die "Missing source directory diffutils-3.12"
cd "diffutils-3.12"
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
log "Removing source tree diffutils-3.12"
rm -rf "diffutils-3.12"

trap - ERR
log_done

