#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / file
# Generated from book; do not edit — re-run generate_scripts.py
# file
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="05-cross-temp/file"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

# Package: file
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "file-5.46" ]; then
  log "Removing prior file-5.46 tree"
  rm -rf "file-5.46"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 file-5.46*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  die "Source tarball not found matching file-5.46"
fi
if [ -n "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "file-5.46" ] || die "Missing source directory file-5.46"
cd "file-5.46"
log "Building in $(pwd)"

log_step 1 5 'configure'
mkdir p build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

log_step 2 5 'configure'
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

log_step 3 5 'make'
make FILE_COMPILE=$(pwd)/build/src/file

log_step 4 5 'make'
make DESTDIR=$LFS install

log_step 5 5 'rm -v $LFS/usr/lib/libmagic.la'
rm -v $LFS/usr/lib/libmagic.la

cd "${LFS_SOURCES:?}"
log "Removing source tree file-5.46"
rm -rf "file-5.46"

trap - ERR
log_done

