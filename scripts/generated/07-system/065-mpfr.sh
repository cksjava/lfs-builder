#!/bin/bash
# LFS 13.0-systemd — 07-system / mpfr
# Generated from book; do not edit — re-run generate_scripts.py
# mpfr
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/mpfr"
log_begin
trap 'log_fail $?' ERR

# Package: mpfr
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "mpfr-4.2.2" ]; then
  log "Removing prior mpfr-4.2.2 tree"
  rm -rf "mpfr-4.2.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 mpfr-4.2.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "mpfr-4.2.2" ]; then
  die "Source tarball not found matching mpfr-4.2.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "mpfr-4.2.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "mpfr-4.2.2" ] || die "Missing source directory mpfr-4.2.2"
cd "mpfr-4.2.2"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 4 'configure'
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

log_step 2 4 'make'
make
make html

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install
make install-html

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree mpfr-4.2.2"
rm -rf "mpfr-4.2.2"

trap - ERR
log_done

