#!/bin/bash
# LFS 13.0-systemd — 07-system / expect
# Generated from book; do not edit — re-run generate_scripts.py
# expect
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/expect"
log_begin
trap 'log_fail $?' ERR

# Package: expect
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "expect5.45.4" ]; then
  log "Removing prior expect5.45.4 tree"
  rm -rf "expect5.45.4"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 expect5.45.4*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "expect5.45.4" ]; then
  die "Source tarball not found matching expect5.45.4"
fi
if [ -n "$TARBALL" ] && [ ! -d "expect5.45.4" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "expect5.45.4" ] || die "Missing source directory expect5.45.4"
cd "expect5.45.4"
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

log_step 1 6 'python3 -c '"'"'from pty import spawn; spawn(["echo", "ok"])'"'"''
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

log_step 2 6 'apply patch'
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch

log_step 3 6 'configure'
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

log_step 4 6 'make'
make

log_step 5 6 'make'
make test

log_step 6 6 'make install'
make install
ln -sfvf expect5.45.4/libexpect5.45.4.so /usr/lib

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree expect5.45.4"
rm -rf "expect5.45.4"

trap - ERR
log_done

