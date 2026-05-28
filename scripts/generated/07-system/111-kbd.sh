#!/bin/bash
# LFS 13.0-systemd — 07-system / kbd
# Generated from book; do not edit — re-run generate_scripts.py
# kbd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/kbd"
log_begin
trap 'log_fail $?' ERR

# Package: kbd
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "kbd-2.9.0" ]; then
  log "Removing prior kbd-2.9.0 tree"
  rm -rf "kbd-2.9.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 kbd-2.9.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "kbd-2.9.0" ]; then
  die "Source tarball not found matching kbd-2.9.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "kbd-2.9.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "kbd-2.9.0" ] || die "Missing source directory kbd-2.9.0"
cd "kbd-2.9.0"
log "Building in $(pwd)"

log_step 1 7 'apply patch'
patch -Np1 -i ../kbd-2.9.0-backspace-1.patch

log_step 2 7 'sed -i '"'"'/RESIZECONS_PROGS=/s/yes/no/'"'"' configure'
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

log_step 3 7 'configure'
./configure --prefix=/usr --disable-vlock

log_step 4 7 'make'
make

log_step 5 7 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 6 7 'make install'
make install

log_step 7 7 'cp -R -v docs/doc -T /usr/share/doc/kbd-2.9.0'
cp -R -v docs/doc -T /usr/share/doc/kbd-2.9.0

cd "${LFS_SOURCES:?}"
log "Removing source tree kbd-2.9.0"
rm -rf "kbd-2.9.0"

trap - ERR
log_done

