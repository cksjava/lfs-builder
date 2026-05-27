#!/bin/bash
# LFS 13.0-systemd — 07-system / systemd
# Generated from book; do not edit — re-run generate_scripts.py
# systemd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/systemd"
log_begin
trap 'log_fail $?' ERR

# Package: systemd
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 systemd-259.1*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "systemd-259.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "systemd-259.1"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 9 'sed -e '"'"'s/GROUP="render"/GROUP="video"/'"'"' \'
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in

log_step 2 9 'mkdir -p build'
mkdir -p build
cd       build

log_step 3 9 'meson setup ..                \'
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

log_step 4 9 'ninja'
ninja

log_step 5 9 'echo '"'"'NAME="Linux From Scratch"'"'"' > /etc/os-release'
echo 'NAME="Linux From Scratch"' > /etc/os-release
unshare -m ninja test

log_step 6 9 'ninja install'
ninja install

log_step 7 9 'extract source archive'
tar -xf ../../systemd-man-pages-259.1.tar.xz \
    --no-same-owner --strip-components=1     \
    -C /usr/share/man

log_step 8 9 'systemd-machine-id-setup'
systemd-machine-id-setup

log_step 9 9 'systemctl preset-all'
systemctl preset-all

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

