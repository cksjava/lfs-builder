#!/bin/bash
# LFS 13.0-systemd — 07-system / bc
# Generated from book; do not edit — re-run generate_scripts.py
# bc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/bc"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: bc
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "bc-7.0.3" ]; then
  log "Removing prior bc-7.0.3 tree"
  rm -rf "bc-7.0.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 bc-7.0.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "bc-7.0.3" ]; then
  die "Source tarball not found matching bc-7.0.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "bc-7.0.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "bc-7.0.3" ] || die "Missing source directory bc-7.0.3"
cd "bc-7.0.3"
log "Building in $(pwd)"

log_step 1 4 'configure'
CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

log_step 2 4 'make'
make

log_step 3 4 'if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make test
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree bc-7.0.3"
rm -rf "bc-7.0.3"

trap - ERR
log_done

