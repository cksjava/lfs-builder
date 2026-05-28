#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / util-linux
# Generated from book; do not edit — re-run generate_scripts.py
# util-linux
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/util-linux"
log_begin
trap 'log_fail $?' ERR

# Package: util-linux
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "util-linux-2.41.3" ]; then
  log "Removing prior util-linux-2.41.3 tree"
  rm -rf "util-linux-2.41.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 util-linux-2.41.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "util-linux-2.41.3" ]; then
  die "Source tarball not found matching util-linux-2.41.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "util-linux-2.41.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "util-linux-2.41.3" ] || die "Missing source directory util-linux-2.41.3"
cd "util-linux-2.41.3"
log "Building in $(pwd)"

log_step 1 4 'mkdir -pv /var/lib/hwclock'
mkdir -pv /var/lib/hwclock

log_step 2 4 'configure'
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3

log_step 3 4 'make'
make

log_step 4 4 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree util-linux-2.41.3"
rm -rf "util-linux-2.41.3"

trap - ERR
log_done

