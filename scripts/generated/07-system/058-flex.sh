#!/bin/bash
# LFS 13.0-systemd — 07-system / flex
# Generated from book; do not edit — re-run generate_scripts.py
# flex
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/flex"
log_begin
trap 'log_fail $?' ERR

# Package: flex
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "flex-2.6.4" ]; then
  log "Removing prior flex-2.6.4 tree"
  rm -rf "flex-2.6.4"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 flex-2.6.4*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "flex-2.6.4" ]; then
  die "Source tarball not found matching flex-2.6.4"
fi
if [ -n "$TARBALL" ] && [ ! -d "flex-2.6.4" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "flex-2.6.4" ] || die "Missing source directory flex-2.6.4"
cd "flex-2.6.4"
log "Building in $(pwd)"

log_step 1 5 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4

log_step 2 5 'make'
make

log_step 3 5 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 5 'make install'
make install

log_step 5 5 'ln -svf flex   /usr/bin/lex'
ln -svf flex   /usr/bin/lex
ln -svf flex.1 /usr/share/man/man1/lex.1

cd "${LFS_SOURCES:?}"
log "Removing source tree flex-2.6.4"
rm -rf "flex-2.6.4"

trap - ERR
log_done

