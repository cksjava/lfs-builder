#!/bin/bash
# LFS 13.0-systemd — 07-system / grub
# Generated from book; do not edit — re-run generate_scripts.py
# grub
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/grub"
log_begin
trap 'log_fail $?' ERR

# Package: grub
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "grub-2.14" ]; then
  log "Removing prior grub-2.14 tree"
  rm -rf "grub-2.14"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 grub-2.14*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "grub-2.14" ]; then
  die "Source tarball not found matching grub-2.14"
fi
if [ -n "$TARBALL" ] && [ ! -d "grub-2.14" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "grub-2.14" ] || die "Missing source directory grub-2.14"
cd "grub-2.14"
log "Building in $(pwd)"

log_step 1 5 'unset {C,CPP,CXX,LD}FLAGS'
unset {C,CPP,CXX,LD}FLAGS

log_step 2 5 'sed '"'"'s/--image-base/--nonexist-linker-option/'"'"' -i configure'
sed 's/--image-base/--nonexist-linker-option/' -i configure

log_step 3 5 'configure'
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

log_step 4 5 'make'
make

log_step 5 5 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree grub-2.14"
rm -rf "grub-2.14"

trap - ERR
log_done

