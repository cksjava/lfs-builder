#!/bin/bash
# LFS 13.0-systemd — 07-system / libxcrypt
# Generated from book; do not edit — re-run generate_scripts.py
# libxcrypt
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/libxcrypt"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: libxcrypt
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "libxcrypt-4.5.2" ]; then
  log "Removing prior libxcrypt-4.5.2 tree"
  rm -rf "libxcrypt-4.5.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 libxcrypt-4.5.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "libxcrypt-4.5.2" ]; then
  die "Source tarball not found matching libxcrypt-4.5.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "libxcrypt-4.5.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "libxcrypt-4.5.2" ] || die "Missing source directory libxcrypt-4.5.2"
cd "libxcrypt-4.5.2"
log "Building in $(pwd)"

log_step 1 6 'sed -i '"'"'/strchr/s/const//'"'"' lib/crypt-{sm3,gost}-yescrypt.c'
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c

log_step 2 6 'configure'
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

log_step 3 6 'make'
make

log_step 4 6 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 6 'make install'
make install

log_step 6 6 'configure'
make distclean
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=glibc  \
            --disable-static             \
            --disable-failure-tokens
make
cp -av --remove-destination .libs/libcrypt.so.1* /usr/lib

cd "${LFS_SOURCES:?}"
log "Removing source tree libxcrypt-4.5.2"
rm -rf "libxcrypt-4.5.2"

trap - ERR
log_done

