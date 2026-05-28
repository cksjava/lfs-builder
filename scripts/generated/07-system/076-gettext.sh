#!/bin/bash
# LFS 13.0-systemd — 07-system / gettext
# Generated from book; do not edit — re-run generate_scripts.py
# gettext
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gettext"
log_begin
trap 'log_fail $?' ERR

# Package: gettext
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gettext-1.0" ]; then
  log "Removing prior gettext-1.0 tree"
  rm -rf "gettext-1.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gettext-1.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  die "Source tarball not found matching gettext-1.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gettext-1.0" ] || die "Missing source directory gettext-1.0"
cd "gettext-1.0"
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
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0

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
chmod -v 0755 /usr/lib/preloadable_libintl.so

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree gettext-1.0"
rm -rf "gettext-1.0"

trap - ERR
log_done

