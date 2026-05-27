#!/bin/bash
# LFS 13.0-systemd — 07-system / file
# Generated from book; do not edit — re-run generate_scripts.py
# file
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: file
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 file-5.46*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "file-5.46" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "file-5.46"

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
