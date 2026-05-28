#!/bin/bash
# LFS 13.0-systemd — 07-system / inetutils
# Generated from book; do not edit — re-run generate_scripts.py
# inetutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/inetutils"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: inetutils
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "inetutils-2.7" ]; then
  log "Removing prior inetutils-2.7 tree"
  rm -rf "inetutils-2.7"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 inetutils-2.7*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "inetutils-2.7" ]; then
  die "Source tarball not found matching inetutils-2.7"
fi
if [ -n "$TARBALL" ] && [ ! -d "inetutils-2.7" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "inetutils-2.7" ] || die "Missing source directory inetutils-2.7"
cd "inetutils-2.7"
log "Building in $(pwd)"

log_step 1 6 'sed -i '"'"'s/def HAVE_TERMCAP_TGETENT/ 1/'"'"' telnet/telnet.c'
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

log_step 2 6 'configure'
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

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

log_step 6 6 'mv -v /usr/{,s}bin/ifconfig'
mv -v /usr/{,s}bin/ifconfig

cd "${LFS_SOURCES:?}"
log "Removing source tree inetutils-2.7"
rm -rf "inetutils-2.7"

trap - ERR
log_done

