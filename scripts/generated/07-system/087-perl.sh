#!/bin/bash
# LFS 13.0-systemd — 07-system / perl
# Generated from book; do not edit — re-run generate_scripts.py
# perl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/perl"
log_begin
trap 'log_fail $?' ERR

# Package: perl
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 perl-5.42.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "perl-5.42.0" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "perl-5.42.0"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 5 'export BUILD_ZLIB=False'
export BUILD_ZLIB=False
export BUILD_BZIP2=0

log_step 2 5 'sh Configure -des                                          \'
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.42/core_perl      \
             -D archlib=/usr/lib/perl5/5.42/core_perl      \
             -D sitelib=/usr/lib/perl5/5.42/site_perl      \
             -D sitearch=/usr/lib/perl5/5.42/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads

log_step 3 5 'make'
make

log_step 4 5 'TEST_JOBS=$(nproc) make test_harness'
TEST_JOBS=$(nproc) make test_harness

log_step 5 5 'make install'
make install
unset BUILD_ZLIB BUILD_BZIP2

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

