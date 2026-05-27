#!/bin/bash
# LFS 13.0-systemd — 07-system / coreutils
# Generated from book; do not edit — re-run generate_scripts.py
# coreutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/coreutils"
log_begin
trap 'log_fail $?' ERR

# Package: coreutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 coreutils-9.10*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "coreutils-9.10" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "coreutils-9.10"
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

log_step 1 10 'apply patch'
patch -Np1 -i ../coreutils-9.10-i18n-1.patch

log_step 2 10 'configure'
autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr

log_step 3 10 'make'
make

log_step 4 10 'make'
make NON_ROOT_USERNAME=tester check-root

log_step 5 10 'getent group tester &>/dev/null || groupadd -g 102 dummy -U tester'
getent group tester &>/dev/null || groupadd -g 102 dummy -U tester

log_step 6 10 'chown -R tester .'
chown -R tester .

log_step 7 10 'su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \'
su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
   < /dev/null

log_step 8 10 'groupdel dummy'
groupdel dummy

log_step 9 10 'make install'
make install

log_step 10 10 'mv -v /usr/bin/chroot /usr/sbin'
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

