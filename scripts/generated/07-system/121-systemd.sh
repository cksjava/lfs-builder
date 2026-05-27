#!/bin/bash
# LFS 13.0-systemd — 07-system / systemd
# Generated from book; do not edit — re-run generate_scripts.py
# systemd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: systemd
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 systemd-259.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "systemd-259.1" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "systemd-259.1"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in
mkdir -p build
cd       build
meson setup ..                \
      --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/systemd-259.1
ninja
echo 'NAME="Linux From Scratch"' > /etc/os-release
unshare -m ninja test
ninja install
tar -xf ../../systemd-man-pages-259.1.tar.xz \
    --no-same-owner --strip-components=1     \
    -C /usr/share/man
systemd-machine-id-setup
systemctl preset-all
CHROOT_EOF
