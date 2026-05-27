#!/bin/bash
# LFS 13.0-systemd — 07-system / kmod
# Generated from book; do not edit — re-run generate_scripts.py
# kmod
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: kmod
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 kmod-34.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "kmod-34.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "kmod-34.2"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
mkdir -p build
cd       build
meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false
ninja
ninja install
CHROOT_EOF
