#!/bin/bash
# LFS 13.0-systemd — 07-system / man-pages
# Generated from book; do not edit — re-run generate_scripts.py
# man-pages
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: man-pages
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 man-pages-6.17*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "man-pages-6.17" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "man-pages-6.17"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
rm -v man3/crypt*
make -R GIT=false prefix=/usr install
CHROOT_EOF
