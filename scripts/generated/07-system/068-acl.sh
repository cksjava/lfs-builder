#!/bin/bash
# LFS 13.0-systemd — 07-system / acl
# Generated from book; do not edit — re-run generate_scripts.py
# acl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/acl"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: acl
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "acl-2.3.2" ]; then
  log "Removing prior acl-2.3.2 tree"
  rm -rf "acl-2.3.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 acl-2.3.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "acl-2.3.2" ]; then
  die "Source tarball not found matching acl-2.3.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "acl-2.3.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "acl-2.3.2" ] || die "Missing source directory acl-2.3.2"
cd "acl-2.3.2"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2

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
log "Removing source tree acl-2.3.2"
rm -rf "acl-2.3.2"

trap - ERR
log_done

