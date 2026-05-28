#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / bison
# Generated from book; do not edit — re-run generate_scripts.py
# bison
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/bison"
log_begin
trap 'log_fail $?' ERR

# Package: bison
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "bison-3.8.2" ]; then
  log "Removing prior bison-3.8.2 tree"
  rm -rf "bison-3.8.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 bison-3.8.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "bison-3.8.2" ]; then
  die "Source tarball not found matching bison-3.8.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "bison-3.8.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "bison-3.8.2" ] || die "Missing source directory bison-3.8.2"
cd "bison-3.8.2"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 3 'configure'
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

log_step 2 3 'make'
make

log_step 3 3 'make install'
make install

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree bison-3.8.2"
rm -rf "bison-3.8.2"

trap - ERR
log_done

