#!/bin/bash
# LFS 13.0-systemd — 07-system / gzip
# Generated from book; do not edit — re-run generate_scripts.py
# gzip
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gzip
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gzip-1.14*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gzip-1.14" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gzip-1.14"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr
make
make check
make install
CHROOT_EOF
