#!/bin/bash
# LFS 13.0-systemd — 07-system / dbus
# Generated from book; do not edit — re-run generate_scripts.py
# dbus
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: dbus
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 d-bus-1.16.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "d-bus-1.16.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "d-bus-1.16.2"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
mkdir build
cd    build
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
ninja
ninja test
ninja install
ln -sfv /etc/machine-id /var/lib/dbus
CHROOT_EOF
