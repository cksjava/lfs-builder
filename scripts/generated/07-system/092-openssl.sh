#!/bin/bash
# LFS 13.0-systemd — 07-system / openssl
# Generated from book; do not edit — re-run generate_scripts.py
# openssl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: openssl
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 openssl-3.6.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "openssl-3.6.1" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "openssl-3.6.1"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make
HARNESS_JOBS=$(nproc) make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.6.1
cp -vfr doc/* /usr/share/doc/openssl-3.6.1
CHROOT_EOF
