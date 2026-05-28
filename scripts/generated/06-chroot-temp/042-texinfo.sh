#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / texinfo
# Generated from book; do not edit — re-run generate_scripts.py
# texinfo
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/texinfo"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"
if [ -z "${COMPILER_PATH:-}" ]; then
  _cc1=$(find /usr/libexec/gcc /usr/lib/gcc /tools/libexec/gcc \
    -name cc1 -type f 2>/dev/null | head -1)
  [ -n "$_cc1" ] && export COMPILER_PATH="$(dirname "$_cc1")"
fi

# Package: texinfo
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "texinfo-7.2" ]; then
  log "Removing prior texinfo-7.2 tree"
  rm -rf "texinfo-7.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 texinfo-7.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "texinfo-7.2" ]; then
  die "Source tarball not found matching texinfo-7.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "texinfo-7.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "texinfo-7.2" ] || die "Missing source directory texinfo-7.2"
cd "texinfo-7.2"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --prefix=/usr

log_step 2 3 'make'
make

log_step 3 3 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree texinfo-7.2"
rm -rf "texinfo-7.2"

trap - ERR
log_done

