#!/bin/bash
# LFS 13.0-systemd — 07-system / expect
# Generated from book; do not edit — re-run generate_scripts.py
# expect
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: expect
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 expect-5.45.4*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "expect-5.45.4" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "expect-5.45.4"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
CHROOT_EOF
