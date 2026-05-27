#!/bin/bash
# LFS 13.0-systemd — 08-config / network
# Generated from book; do not edit — re-run generate_scripts.py
# network
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/network"
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

log_step 1 17 'systemctl disable systemd-networkd-wait-online'
systemctl disable systemd-networkd-wait-online

log_step 2 17 'ln -sf /dev/null /etc/systemd/network/99-default.link'
ln -sf /dev/null /etc/systemd/network/99-default.link

log_step 3 17 'write configuration file'
cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Change the MAC address as appropriate for your network device
MACAddress=12:34:45:78:90:AB

log_step 4 17 '[Link]'
[Link]
Name=ether0
EOF

log_step 5 17 'write configuration file'
cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=<network-device-name>

log_step 6 17 '[Network]'
[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
Domains=<Your Domain Name>
EOF

log_step 7 17 'write configuration file'
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

log_step 8 17 '[Network]'
[Network]
DHCP=ipv4

log_step 9 17 '[DHCPv4]'
[DHCPv4]
UseDomains=true
EOF

log_step 10 17 'systemctl disable systemd-resolved'
systemctl disable systemd-resolved

log_step 11 17 'write configuration file'
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

log_step 12 17 'domain <Your Domain Name>'
domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>

log_step 13 17 '# End /etc/resolv.conf'
# End /etc/resolv.conf
EOF

log_step 14 17 'echo "<lfs>" > /etc/hostname'
echo "<lfs>" > /etc/hostname

log_step 15 17 'write configuration file'
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

log_step 16 17 '<192.168.0.2> <FQDN> [alias1] [alias2] ...'
<192.168.0.2> <FQDN> [alias1] [alias2] ...
::1       ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

log_step 17 17 '# End /etc/hosts'
# End /etc/hosts
EOF

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

