#!/bin/bash
# LFS 13.0-systemd — 07-system / xml-parser
# Generated from book; do not edit — re-run generate_scripts.py
# xml-parser
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/xml-parser"
log_begin
trap 'log_fail $?' ERR

# Package: xml-parser
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "XML-Parser-2.47" ]; then
  log "Removing prior XML-Parser-2.47 tree"
  rm -rf "XML-Parser-2.47"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 XML-Parser-2.47*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "XML-Parser-2.47" ]; then
  die "Source tarball not found matching XML-Parser-2.47"
fi
if [ -n "$TARBALL" ] && [ ! -d "XML-Parser-2.47" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "XML-Parser-2.47" ] || die "Missing source directory XML-Parser-2.47"
cd "XML-Parser-2.47"
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

log_step 1 4 'perl Makefile.PL'
perl Makefile.PL

log_step 2 4 'make'
make

log_step 3 4 'make'
make test

log_step 4 4 'make install'
make install

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree XML-Parser-2.47"
rm -rf "XML-Parser-2.47"

trap - ERR
log_done

