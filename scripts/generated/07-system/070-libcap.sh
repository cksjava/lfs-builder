#!/bin/bash
# LFS 13.0-systemd — 07-system / libcap
# Generated from book; do not edit — re-run generate_scripts.py
# libcap
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: libcap
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 libcap-2.77*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "libcap-2.77" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "libcap-2.77"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
CHROOT_EOF
