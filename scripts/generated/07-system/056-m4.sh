#!/bin/bash
# LFS 13.0-systemd — 07-system / m4
# Generated from book; do not edit — re-run generate_scripts.py
# m4
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/m4"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: m4
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "m4-1.4.21" ]; then
  log "Removing prior m4-1.4.21 tree"
  rm -rf "m4-1.4.21"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 m4-1.4.21*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "m4-1.4.21" ]; then
  die "Source tarball not found matching m4-1.4.21"
fi
if [ -n "$TARBALL" ] && [ ! -d "m4-1.4.21" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "m4-1.4.21" ] || die "Missing source directory m4-1.4.21"
cd "m4-1.4.21"
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
log "Removing source tree m4-1.4.21"
rm -rf "m4-1.4.21"

trap - ERR
log_done

