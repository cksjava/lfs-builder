#!/bin/bash
# LFS 13.0-systemd — 07-system / file
# Generated from book; do not edit — re-run generate_scripts.py
# file
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/file"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: file
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "file-5.46" ]; then
  log "Removing prior file-5.46 tree"
  rm -rf "file-5.46"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 file-5.46*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  die "Source tarball not found matching file-5.46"
fi
if [ -n "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "file-5.46" ] || die "Missing source directory file-5.46"
cd "file-5.46"
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
log "Removing source tree file-5.46"
rm -rf "file-5.46"

trap - ERR
log_done

