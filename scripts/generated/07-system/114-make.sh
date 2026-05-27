#!/bin/bash
# LFS 13.0-systemd — 07-system / make
# Generated from book; do not edit — re-run generate_scripts.py
# make
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: make
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 make-4.4.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "make-4.4.1" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "make-4.4.1"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
CHROOT_EOF
