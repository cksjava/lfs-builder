#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / perl
# Generated from book; do not edit — re-run generate_scripts.py
# perl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/perl"
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

# Package: perl
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "perl-5.42.0" ]; then
  log "Removing prior perl-5.42.0 tree"
  rm -rf "perl-5.42.0"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 perl-5.42.0*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "perl-5.42.0" ]; then
  die "Source tarball not found matching perl-5.42.0"
fi
if [ -n "$TARBALL" ] && [ ! -d "perl-5.42.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "perl-5.42.0" ] || die "Missing source directory perl-5.42.0"
cd "perl-5.42.0"
log "Building in $(pwd)"

log_step 1 3 'sh Configure -des                                         \'
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl

log_step 2 3 'make'
make

log_step 3 3 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree perl-5.42.0"
rm -rf "perl-5.42.0"

trap - ERR
log_done

