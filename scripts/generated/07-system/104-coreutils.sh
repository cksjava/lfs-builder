#!/bin/bash
# LFS 13.0-systemd — 07-system / coreutils
# Generated from book; do not edit — re-run generate_scripts.py
# coreutils
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: coreutils
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 coreutils-9.10*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "coreutils-9.10" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "coreutils-9.10"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
patch -Np1 -i ../coreutils-9.10-i18n-1.patch
autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr
make
make NON_ROOT_USERNAME=tester check-root
groupadd -g 102 dummy -U tester
chown -R tester .
su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
   < /dev/null
groupdel dummy
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
CHROOT_EOF
