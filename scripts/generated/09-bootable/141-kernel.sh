#!/bin/bash
# LFS 13.0-systemd — 09-bootable / kernel
# Generated from book; do not edit — re-run generate_scripts.py
# kernel
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
make mrproper
make
make modules_install
mount /boot
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.18.10-lfs-13.0-systemd
cp -iv System.map /boot/System.map-6.18.10
cp -iv .config /boot/config-6.18.10
cp -r Documentation -T /usr/share/doc/linux-6.18.10
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
# End /etc/modprobe.d/usb.conf
EOF
CHROOT_EOF
