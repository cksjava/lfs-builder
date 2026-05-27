#!/bin/bash
# LFS 13.0-systemd — 07-system / procps-ng
# Generated from book; do not edit — re-run generate_scripts.py
# procps-ng
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: procps-ng
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 procps-ng-4.0.6*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "procps-ng-4.0.6" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "procps-ng-4.0.6"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.6 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
            --with-systemd
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
CHROOT_EOF
