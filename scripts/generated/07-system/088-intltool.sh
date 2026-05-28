#!/bin/bash
# LFS 13.0-systemd — 07-system / intltool
# Generated from book; do not edit — re-run generate_scripts.py
# intltool
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/intltool"
log_begin
trap 'log_fail $?' ERR

# Package: intltool
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "intltool-0.51.0" ]; then
  log "Removing prior intltool-0.51.0 tree"
  rm -rf "intltool-0.51.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 intltool-0.51.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "intltool-0.51.0" ]; then
  die "Source tarball not found matching intltool-0.51.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "intltool-0.51.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "intltool-0.51.0" ] || die "Missing source directory intltool-0.51.0"
cd "intltool-0.51.0"
log "Building in $(pwd)"

log_step 1 5 'sed -i '"'"'s:\\\${:\\\$\\{:'"'"' intltool-update.in'
sed -i 's:\\\${:\\\$\\{:' intltool-update.in

log_step 2 5 'configure'
./configure --prefix=/usr

log_step 3 5 'make'
make

log_step 4 5 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 5 'make install'
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd "${LFS_SOURCES:?}"
log "Removing source tree intltool-0.51.0"
rm -rf "intltool-0.51.0"

trap - ERR
log_done

