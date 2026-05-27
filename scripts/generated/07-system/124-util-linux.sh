#!/bin/bash
# LFS 13.0-systemd — 07-system / util-linux
# Generated from book; do not edit — re-run generate_scripts.py
# util-linux
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/util-linux"
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

log_step 1 5 'configure'
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3

log_step 2 5 'make'
make

log_step 3 5 'bash tests/run.sh --srcdir=$PWD --builddir=$PWD'
bash tests/run.sh --srcdir=$PWD --builddir=$PWD

log_step 4 5 'make check (test suite)'
touch /etc/fstab
chown -R tester .
su tester -c "make -k check"

log_step 5 5 'make install'
make install

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

