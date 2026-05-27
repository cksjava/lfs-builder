#!/bin/bash
# LFS 13.0-systemd — 07-system / bash
# Generated from book; do not edit — re-run generate_scripts.py
# bash
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: bash
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 bash-5.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "bash-5.3" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "bash-5.3"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3
make
chown -R tester .
LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
make install
exec /usr/bin/bash --login
CHROOT_EOF
