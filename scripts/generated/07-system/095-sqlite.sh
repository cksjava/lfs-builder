#!/bin/bash
# LFS 13.0-systemd — 07-system / sqlite
# Generated from book; do not edit — re-run generate_scripts.py
# sqlite
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: sqlite
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 sqlite-3510200*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sqlite-3510200" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "sqlite-3510200"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
tar -xf ../sqlite-doc-3510200.tar.xz
./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -D SQLITE_SECURE_DELETE=1"
make LDFLAGS.rpath=""
make install
install -v -m755 -d /usr/share/doc/sqlite-3.51.2
cp -v -R sqlite-doc-3510200/* /usr/share/doc/sqlite-3.51.2
CHROOT_EOF
