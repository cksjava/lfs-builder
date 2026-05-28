#!/bin/bash
# LFS 13.0-systemd — 07-system / systemd
# Generated from book; do not edit — re-run generate_scripts.py
# systemd
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/systemd"
log_begin
trap 'log_fail $?' ERR

# Package: systemd
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "systemd-259.1" ]; then
  log "Removing prior systemd-259.1 tree"
  rm -rf "systemd-259.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 systemd-259.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "systemd-259.1" ]; then
  die "Source tarball not found matching systemd-259.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "systemd-259.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "systemd-259.1" ] || die "Missing source directory systemd-259.1"
cd "systemd-259.1"
log "Building in $(pwd)"

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

log_step 5 9 'if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  echo 'NAME="Linux From Scratch"' > /etc/os-release
  unshare -m ninja test
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

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

cd "${LFS_SOURCES:?}"
log "Removing source tree systemd-259.1"
rm -rf "systemd-259.1"

trap - ERR
log_done

