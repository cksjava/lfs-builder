#!/bin/bash
# LFS 13.0-systemd — 07-system / pcre2
# Generated from book; do not edit — re-run generate_scripts.py
# pcre2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/pcre2"
log_begin
trap 'log_fail $?' ERR

# Package: pcre2
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "pcre2-10.47" ]; then
  log "Removing prior pcre2-10.47 tree"
  rm -rf "pcre2-10.47"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 pcre2-10.47*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "pcre2-10.47" ]; then
  die "Source tarball not found matching pcre2-10.47"
fi
if [ -n "$TARBALL" ] && [ ! -d "pcre2-10.47" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "pcre2-10.47" ] || die "Missing source directory pcre2-10.47"
cd "pcre2-10.47"
log "Building in $(pwd)"

log_step 1 4 'configure'
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static

log_step 2 4 'make'
make

log_step 3 4 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 4 4 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree pcre2-10.47"
rm -rf "pcre2-10.47"

trap - ERR
log_done

