#!/bin/bash
# LFS 13.0-systemd — 07-system / grep
# Generated from book; do not edit — re-run generate_scripts.py
# grep
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/grep"
log_begin
trap 'log_fail $?' ERR

# Package: grep
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "grep-3.12" ]; then
  log "Removing prior grep-3.12 tree"
  rm -rf "grep-3.12"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 grep-3.12*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "grep-3.12" ]; then
  die "Source tarball not found matching grep-3.12"
fi
if [ -n "$TARBALL" ] && [ ! -d "grep-3.12" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "grep-3.12" ] || die "Missing source directory grep-3.12"
cd "grep-3.12"
log "Building in $(pwd)"

log_step 1 5 'sed -i "s/echo/#echo/" src/egrep.sh'
sed -i "s/echo/#echo/" src/egrep.sh

log_step 2 5 'configure'
./configure --prefix=/usr

log_step 3 5 'make'
make

log_step 4 5 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 5 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree grep-3.12"
rm -rf "grep-3.12"

trap - ERR
log_done

