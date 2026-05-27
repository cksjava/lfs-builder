#!/bin/bash
# LFS 13.0-systemd — 07-system / bison
# Generated from book; do not edit — re-run generate_scripts.py
# bison
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: bison
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 bison-3.8.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "bison-3.8.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "bison-3.8.2"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make
make check
make install
CHROOT_EOF
