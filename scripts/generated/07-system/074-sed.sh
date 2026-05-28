#!/bin/bash
# LFS 13.0-systemd — 07-system / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/sed"
log_begin
trap 'log_fail $?' ERR

# Package: sed
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "sed-4.9" ]; then
  log "Removing prior sed-4.9 tree"
  rm -rf "sed-4.9"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  die "Source tarball not found matching sed-4.9"
fi
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "sed-4.9" ] || die "Missing source directory sed-4.9"
cd "sed-4.9"
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

log_step 1 4 'configure'
./configure --prefix=/usr

log_step 2 4 'make'
make
make html

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  chown -R tester .
  su tester -c "PATH=$PATH make check"
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree sed-4.9"
rm -rf "sed-4.9"

trap - ERR
log_done

