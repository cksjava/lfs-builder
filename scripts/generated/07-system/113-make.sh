#!/bin/bash
# LFS 13.0-systemd — 07-system / make
# Generated from book; do not edit — re-run generate_scripts.py
# make
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/make"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: make
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "make-4.4.1" ]; then
  log "Removing prior make-4.4.1 tree"
  rm -rf "make-4.4.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 make-4.4.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "make-4.4.1" ]; then
  die "Source tarball not found matching make-4.4.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "make-4.4.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "make-4.4.1" ] || die "Missing source directory make-4.4.1"
cd "make-4.4.1"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  chown -R tester .
  su tester -c "PATH=$PATH make check"
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree make-4.4.1"
rm -rf "make-4.4.1"

trap - ERR
log_done

