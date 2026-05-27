#!/bin/bash
# LFS 13.0-systemd — 09-bootable / kernel
# Generated from book; do not edit — re-run generate_scripts.py
# kernel
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="09-bootable/kernel"
log_begin
trap 'log_fail $?' ERR

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 11 'make'
make mrproper

log_step 2 11 'make'
make

log_step 3 11 'make'
make modules_install

log_step 4 11 'mount /boot'
mount /boot

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

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

