#!/bin/bash
# LFS 13.0-systemd — 07-system / zstd
# Generated from book; do not edit — re-run generate_scripts.py
# zstd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/zstd"
log_begin
trap 'log_fail $?' ERR

# Package: zstd
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "zstd-1.5.7" ]; then
  log "Removing prior zstd-1.5.7 tree"
  rm -rf "zstd-1.5.7"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 zstd-1.5.7*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "zstd-1.5.7" ]; then
  die "Source tarball not found matching zstd-1.5.7"
fi
if [ -n "$TARBALL" ] && [ ! -d "zstd-1.5.7" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "zstd-1.5.7" ] || die "Missing source directory zstd-1.5.7"
cd "zstd-1.5.7"
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

log_step 1 4 'make'
make prefix=/usr

log_step 2 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 3 4 'make'
make prefix=/usr install

log_step 4 4 'rm -v /usr/lib/libzstd.a'
rm -v /usr/lib/libzstd.a

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree zstd-1.5.7"
rm -rf "zstd-1.5.7"

trap - ERR
log_done

