#!/bin/bash
# LFS 13.0-systemd — 07-system / bash
# Generated from book; do not edit — re-run generate_scripts.py
# bash
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/bash"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: bash
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "bash-5.3" ]; then
  log "Removing prior bash-5.3 tree"
  rm -rf "bash-5.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 bash-5.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "bash-5.3" ]; then
  die "Source tarball not found matching bash-5.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "bash-5.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "bash-5.3" ] || die "Missing source directory bash-5.3"
cd "bash-5.3"
log "Building in $(pwd)"

log_step 1 5 'configure'
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

log_step 2 5 'make'
make

log_step 3 5 'chown -R tester .'
chown -R tester .

log_step 4 5 'LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"'
LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

log_step 5 5 'make install'
make install

cd "${LFS_SOURCES:?}"
log "Removing source tree bash-5.3"
rm -rf "bash-5.3"

trap - ERR
log_done

