#!/bin/bash
# LFS 13.0-systemd — 07-system / groff
# Generated from book; do not edit — re-run generate_scripts.py
# groff
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: groff
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 groff-1.23.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "groff-1.23.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "groff-1.23.0"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
PAGE=<paper_size> ./configure --prefix=/usr
make
make check
make install
CHROOT_EOF
