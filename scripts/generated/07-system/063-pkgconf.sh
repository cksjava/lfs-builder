#!/bin/bash
# LFS 13.0-systemd — 07-system / pkgconf
# Generated from book; do not edit — re-run generate_scripts.py
# pkgconf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: pkgconf
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 pkgconf-2.5.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "pkgconf-2.5.1" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "pkgconf-2.5.1"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1
make
make install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
CHROOT_EOF
