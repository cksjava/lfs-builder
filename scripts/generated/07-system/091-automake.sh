#!/bin/bash
# LFS 13.0-systemd — 07-system / automake
# Generated from book; do not edit — re-run generate_scripts.py
# automake
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: automake
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 automake-1.18.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "automake-1.18.1" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "automake-1.18.1"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
make
make -j$(($(nproc)>4?$(nproc):4)) check
make install
CHROOT_EOF
