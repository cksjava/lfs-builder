#!/bin/bash
# LFS 13.0-systemd — 07-system / libelf
# Generated from book; do not edit — re-run generate_scripts.py
# libelf
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: libelf
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 elfutils-0.194*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "elfutils-0.194" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "elfutils-0.194"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy
make -C lib
make -C libelf
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
CHROOT_EOF
