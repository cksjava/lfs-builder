#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / util-linux
# Generated from book; do not edit — re-run generate_scripts.py
# util-linux
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="06-chroot-temp/util-linux"
log_begin
trap 'log_fail $?' ERR

# Package: util-linux
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 util-linux-2.41.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "util-linux-2.41.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "util-linux-2.41.3"
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

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

