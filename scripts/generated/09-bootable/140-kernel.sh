#!/bin/bash
# LFS 13.0-systemd — 09-bootable / kernel
# Generated from book; do not edit — re-run generate_scripts.py
# kernel
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="09-bootable/kernel"
log_begin
trap 'log_fail $?' ERR

# Package: kernel
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 linux-6.18.10*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "linux-6.18.10" ]; then
  die "Source tarball not found matching linux-6.18.10"
fi
if [ -n "$TARBALL" ] && [ ! -d "linux-6.18.10" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "linux-6.18.10" ] || die "Missing source directory linux-6.18.10"
cd "linux-6.18.10"
log "Building in $(pwd)"

log_step 1 11 'make'
make mrproper

log_step 2 11 'make'
make

log_step 3 11 'make'
make modules_install

log_step 4 11 'mountpoint -q /boot 2>/dev/null || mount /boot'
mountpoint -q /boot 2>/dev/null || mount /boot

log_step 5 11 'cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.18.10-lfs-13.0-systemd'
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.18.10-lfs-13.0-systemd

log_step 6 11 'cp -iv System.map /boot/System.map-6.18.10'
cp -iv System.map /boot/System.map-6.18.10

log_step 7 11 'cp -iv .config /boot/config-6.18.10'
cp -iv .config /boot/config-6.18.10

log_step 8 11 'cp -r Documentation -T /usr/share/doc/linux-6.18.10'
cp -r Documentation -T /usr/share/doc/linux-6.18.10

log_step 9 11 'write configuration file'
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

log_step 10 11 'install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd...'
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

log_step 11 11 '# End /etc/modprobe.d/usb.conf'
# End /etc/modprobe.d/usb.conf
EOF

cd "${LFS_SOURCES:?}"
log "Removing source tree linux-6.18.10"
rm -rf "linux-6.18.10"

trap - ERR
log_done

