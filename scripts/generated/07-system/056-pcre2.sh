#!/bin/bash
# LFS 13.0-systemd — 07-system / pcre2
# Generated from book; do not edit — re-run generate_scripts.py
# pcre2
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: pcre2
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 pcre2-10.47*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "pcre2-10.47" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "pcre2-10.47"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static
make
make check
make install
CHROOT_EOF
