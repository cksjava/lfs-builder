#!/bin/bash
# LFS 13.0-systemd — 07-system / jinja2
# Generated from book; do not edit — re-run generate_scripts.py
# jinja2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: jinja2
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 jinja2-3.1.6*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "jinja2-3.1.6" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "jinja2-3.1.6"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Jinja2
CHROOT_EOF
