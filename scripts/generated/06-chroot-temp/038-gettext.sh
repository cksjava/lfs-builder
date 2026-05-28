#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / gettext
# Generated from book; do not edit — re-run generate_scripts.py
# gettext
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/gettext"
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

# Package: gettext
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "gettext-1.0" ]; then
  log "Removing prior gettext-1.0 tree"
  rm -rf "gettext-1.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 gettext-1.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  die "Source tarball not found matching gettext-1.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "gettext-1.0" ] || die "Missing source directory gettext-1.0"
cd "gettext-1.0"
log "Building in $(pwd)"

log_step 1 3 'configure'
./configure --disable-shared

log_step 2 3 'make'
make

log_step 3 3 'cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin'
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd "${LFS_SOURCES:?}"
log "Removing source tree gettext-1.0"
rm -rf "gettext-1.0"

trap - ERR
log_done

