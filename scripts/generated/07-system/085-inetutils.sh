#!/bin/bash
# LFS 13.0-systemd — 07-system / inetutils
# Generated from book; do not edit — re-run generate_scripts.py
# inetutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: inetutils
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 inetutils-2.7*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "inetutils-2.7" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "inetutils-2.7"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
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
make
make check
make install
mv -v /usr/{,s}bin/ifconfig
CHROOT_EOF
