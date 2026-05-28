#!/bin/bash
# LFS 13.0-systemd — 07-system / gmp
# Generated from book; do not edit — re-run generate_scripts.py
# gmp
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gmp"
log_begin
trap 'log_fail $?' ERR

# Package: gmp
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gmp-6.3.0" ]; then
  log "Removing prior gmp-6.3.0 tree"
  rm -rf "gmp-6.3.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gmp-6.3.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gmp-6.3.0" ]; then
  die "Source tarball not found matching gmp-6.3.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "gmp-6.3.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gmp-6.3.0" ] || die "Missing source directory gmp-6.3.0"
cd "gmp-6.3.0"
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

log_step 1 7 'configure'
ABI=32 ./configure ...

log_step 2 7 'sed -i '"'"'/long long t1;/,+1s/()/(...)/'"'"' configure'
sed -i '/long long t1;/,+1s/()/(...)/' configure

log_step 3 7 'configure'
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

log_step 4 7 'make'
make
make html

log_step 5 7 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check 2>&1 | tee gmp-check-log
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 6 7 'awk '"'"'/# PASS:/{total+=$3} ; END{print total}'"'"' gmp-check-log'
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

log_step 7 7 'make install'
make install
make install-html

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree gmp-6.3.0"
rm -rf "gmp-6.3.0"

trap - ERR
log_done

