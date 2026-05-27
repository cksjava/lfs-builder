#!/bin/bash
# LFS 13.0-systemd — 07-system / flex
# Generated from book; do not edit — re-run generate_scripts.py
# flex
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: flex
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 flex-2.6.4*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "flex-2.6.4" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "flex-2.6.4"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4
make
make check
make install
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1
CHROOT_EOF
