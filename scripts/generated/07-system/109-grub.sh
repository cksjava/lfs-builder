#!/bin/bash
# LFS 13.0-systemd — 07-system / grub
# Generated from book; do not edit — re-run generate_scripts.py
# grub
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: grub
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 grub-2.14*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "grub-2.14" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "grub-2.14"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
unset {C,CPP,CXX,LD}FLAGS
sed 's/--image-base/--nonexist-linker-option/' -i configure
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror
make
make install
CHROOT_EOF
