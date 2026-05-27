#!/bin/bash
# LFS 13.0-systemd — 07-system / gawk
# Generated from book; do not edit — re-run generate_scripts.py
# gawk
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: gawk
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 gawk-5.3.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "gawk-5.3.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "gawk-5.3.2"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
rm -f /usr/bin/gawk-5.3.2
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2
CHROOT_EOF
