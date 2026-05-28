#!/bin/bash
# LFS 13.0-systemd — 07-system / gawk
# Generated from book; do not edit — re-run generate_scripts.py
# gawk
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/gawk"
log_begin
trap 'log_fail $?' ERR

# Package: gawk
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gawk-5.3.2" ]; then
  log "Removing prior gawk-5.3.2 tree"
  rm -rf "gawk-5.3.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gawk-5.3.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gawk-5.3.2" ]; then
  die "Source tarball not found matching gawk-5.3.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "gawk-5.3.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gawk-5.3.2" ] || die "Missing source directory gawk-5.3.2"
cd "gawk-5.3.2"
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

log_step 1 7 'sed -i '"'"'s/extras//'"'"' Makefile.in'
sed -i 's/extras//' Makefile.in

log_step 2 7 'configure'
./configure --prefix=/usr

log_step 3 7 'make'
make

log_step 4 7 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  chown -R tester .
  su tester -c "PATH=$PATH make check"
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 7 'make install'
rm -f /usr/bin/gawk-5.3.2
make install

log_step 6 7 'ln -svf gawk.1 /usr/share/man/man1/awk.1'
ln -svf gawk.1 /usr/share/man/man1/awk.1

log_step 7 7 'install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/...'
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree gawk-5.3.2"
rm -rf "gawk-5.3.2"

trap - ERR
log_done

