#!/bin/bash
# LFS 13.0-systemd — 07-system / inetutils
# Generated from book; do not edit — re-run generate_scripts.py
# inetutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/inetutils"
log_begin
trap 'log_fail $?' ERR

# Package: inetutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 inetutils-2.7*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "inetutils-2.7" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "inetutils-2.7"
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

log_step 1 6 'sed -i '"'"'s/def HAVE_TERMCAP_TGETENT/ 1/'"'"' telnet/telnet.c'
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

log_step 2 6 'configure'
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

log_step 3 6 'make'
make

log_step 4 6 'make check (test suite)'
make check

log_step 5 6 'make install'
make install

log_step 6 6 'mv -v /usr/{,s}bin/ifconfig'
mv -v /usr/{,s}bin/ifconfig

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

