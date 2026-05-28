#!/bin/bash
# LFS 13.0-systemd — 07-system / openssl
# Generated from book; do not edit — re-run generate_scripts.py
# openssl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/openssl"
log_begin
trap 'log_fail $?' ERR

# Package: openssl
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "openssl-3.6.1" ]; then
  log "Removing prior openssl-3.6.1 tree"
  rm -rf "openssl-3.6.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 openssl-3.6.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "openssl-3.6.1" ]; then
  die "Source tarball not found matching openssl-3.6.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "openssl-3.6.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "openssl-3.6.1" ] || die "Missing source directory openssl-3.6.1"
cd "openssl-3.6.1"
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

log_step 1 6 './config --prefix=/usr         \'
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

log_step 2 6 'make'
make

log_step 3 6 'HARNESS_JOBS=$(nproc) make test'
HARNESS_JOBS=$(nproc) make test

log_step 4 6 'sed -i '"'"'/INSTALL_LIBS/s/libcrypto.a libssl.a//'"'"' Makefile'
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

log_step 5 6 'mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.6.1'
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.6.1

log_step 6 6 'cp -vfr doc/* /usr/share/doc/openssl-3.6.1'
cp -vfr doc/* /usr/share/doc/openssl-3.6.1

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree openssl-3.6.1"
rm -rf "openssl-3.6.1"

trap - ERR
log_done

