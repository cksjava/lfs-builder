#!/bin/bash
# LFS 13.0-systemd — 07-system / shadow
# Generated from book; do not edit — re-run generate_scripts.py
# shadow
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/shadow"
log_begin
trap 'log_fail $?' ERR

# Package: shadow
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 shadow-4.19.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "shadow-4.19.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "shadow-4.19.3"
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

log_step 1 9 'sed -i '"'"'s/groups$(EXEEXT) //'"'"' src/Makefile.in'
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

log_step 2 9 'sed -e '"'"'s:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:'"'"' \'
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

log_step 3 9 'configure'
touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --disable-logind    \
            --with-group-name-max-length=32

log_step 4 9 'make'
make

log_step 5 9 'make'
make exec_prefix=/usr install
make -C man install-man

log_step 6 9 'pwconv'
pwconv

log_step 7 9 'grpconv'
grpconv

log_step 8 9 'mkdir -p /etc/default'
mkdir -p /etc/default
useradd -D --gid 999

log_step 9 9 'sed -i '"'"'/MAIL/s/yes/no/'"'"' /etc/default/useradd'
sed -i '/MAIL/s/yes/no/' /etc/default/useradd

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

