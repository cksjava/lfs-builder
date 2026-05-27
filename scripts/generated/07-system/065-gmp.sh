#!/bin/bash
# LFS 13.0-systemd — 07-system / gmp
# Generated from book; do not edit — re-run generate_scripts.py
# gmp
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/gmp"
log_begin
trap 'log_fail $?' ERR

# Package: gmp
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gmp-6.3.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gmp-6.3.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "gmp-6.3.0"
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
make check 2>&1 | tee gmp-check-log

log_step 6 7 'awk '"'"'/# PASS:/{total+=$3} ; END{print total}'"'"' gmp-check-log'
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

log_step 7 7 'make install'
make install
make install-html

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

