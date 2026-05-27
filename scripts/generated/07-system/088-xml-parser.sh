#!/bin/bash
# LFS 13.0-systemd — 07-system / xml-parser
# Generated from book; do not edit — re-run generate_scripts.py
# xml-parser
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: xml-parser
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 xml-parser-2.47*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "xml-parser-2.47" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "xml-parser-2.47"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
perl Makefile.PL
make
make test
make install
CHROOT_EOF
