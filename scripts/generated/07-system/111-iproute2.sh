#!/bin/bash
# LFS 13.0-systemd — 07-system / iproute2
# Generated from book; do not edit — re-run generate_scripts.py
# iproute2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: iproute2
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 iproute2-6.18.0*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "iproute2-6.18.0" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "iproute2-6.18.0"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.18.0
CHROOT_EOF
