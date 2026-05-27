#!/bin/bash
# LFS 13.0-systemd — 05-cross-temp / coreutils
# Generated from book; do not edit — re-run generate_scripts.py
# coreutils
# RUN_AS: lfs
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

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
