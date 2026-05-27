#!/bin/bash
# LFS 13.0-systemd — 07-system / util-linux
# Generated from book; do not edit — re-run generate_scripts.py
# util-linux
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: util-linux
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 util-linux-2.41.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "util-linux-2.41.3" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "util-linux-2.41.3"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3
make
bash tests/run.sh --srcdir=$PWD --builddir=$PWD
touch /etc/fstab
chown -R tester .
su tester -c "make -k check"
make install
CHROOT_EOF
