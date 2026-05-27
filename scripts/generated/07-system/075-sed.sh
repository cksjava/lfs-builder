#!/bin/bash
# LFS 13.0-systemd — 07-system / sed
# Generated from book; do not edit — re-run generate_scripts.py
# sed
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: sed
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 sed-4.9*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sed-4.9" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "sed-4.9"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr
make
make html
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9
CHROOT_EOF
