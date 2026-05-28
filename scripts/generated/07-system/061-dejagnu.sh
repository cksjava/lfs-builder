#!/bin/bash
# LFS 13.0-systemd — 07-system / dejagnu
# Generated from book; do not edit — re-run generate_scripts.py
# dejagnu
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/dejagnu"
log_begin
trap 'log_fail $?' ERR

# Package: dejagnu
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "dejagnu-1.6.3" ]; then
  log "Removing prior dejagnu-1.6.3 tree"
  rm -rf "dejagnu-1.6.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 dejagnu-1.6.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "dejagnu-1.6.3" ]; then
  die "Source tarball not found matching dejagnu-1.6.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "dejagnu-1.6.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "dejagnu-1.6.3" ] || die "Missing source directory dejagnu-1.6.3"
cd "dejagnu-1.6.3"
log "Building in $(pwd)"

log_step 1 4 'mkdir -vp build'
mkdir -vp build
cd       build

log_step 2 4 'configure'
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cd "${LFS_SOURCES:?}"
log "Removing source tree dejagnu-1.6.3"
rm -rf "dejagnu-1.6.3"

trap - ERR
log_done

