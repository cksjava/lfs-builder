#!/bin/bash
# LFS 13.0-systemd — 07-system / wheel
# Generated from book; do not edit — re-run generate_scripts.py
# wheel
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: wheel
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 wheel-0.46.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "wheel-0.46.3" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "wheel-0.46.3"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist wheel
CHROOT_EOF
