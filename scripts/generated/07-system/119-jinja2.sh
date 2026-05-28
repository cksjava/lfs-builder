#!/bin/bash
# LFS 13.0-systemd — 07-system / jinja2
# Generated from book; do not edit — re-run generate_scripts.py
# jinja2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/jinja2"
log_begin
trap 'log_fail $?' ERR

# Package: jinja2
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "jinja2-3.1.6" ]; then
  log "Removing prior jinja2-3.1.6 tree"
  rm -rf "jinja2-3.1.6"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 jinja2-3.1.6*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "jinja2-3.1.6" ]; then
  die "Source tarball not found matching jinja2-3.1.6"
fi
if [ -n "$TARBALL" ] && [ ! -d "jinja2-3.1.6" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "jinja2-3.1.6" ] || die "Missing source directory jinja2-3.1.6"
cd "jinja2-3.1.6"
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

log_step 1 2 'pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

log_step 2 2 'pip3 install --no-index --find-links dist Jinja2'
pip3 install --no-index --find-links dist Jinja2

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree jinja2-3.1.6"
rm -rf "jinja2-3.1.6"

trap - ERR
log_done

