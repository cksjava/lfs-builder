#!/bin/bash
# LFS 13.0-systemd — 07-system / gettext
# Generated from book; do not edit — re-run generate_scripts.py
# gettext
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gettext
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gettext-1.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gettext-1.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gettext-1.0"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0
make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
CHROOT_EOF
