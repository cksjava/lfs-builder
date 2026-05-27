#!/bin/bash
# LFS 13.0-systemd — 07-system / tar
# Generated from book; do not edit — re-run generate_scripts.py
# tar
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: tar
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 tar-1.35*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "tar-1.35" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "tar-1.35"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35
CHROOT_EOF
