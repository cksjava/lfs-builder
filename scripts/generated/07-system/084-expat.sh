#!/bin/bash
# LFS 13.0-systemd — 07-system / expat
# Generated from book; do not edit — re-run generate_scripts.py
# expat
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: expat
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 expat-2.7.4*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "expat-2.7.4" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "expat-2.7.4"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.4
make
make check
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.4
CHROOT_EOF
