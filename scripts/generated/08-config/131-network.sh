#!/bin/bash
# LFS 13.0-systemd — 08-config / network
# Generated from book; do not edit — re-run generate_scripts.py
# network
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
systemctl disable systemd-networkd-wait-online
ln -s /dev/null /etc/systemd/network/99-default.link
cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Change the MAC address as appropriate for your network device
MACAddress=12:34:45:78:90:AB
[Link]
Name=ether0
EOF
cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=<network-device-name>
[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
Domains=<Your Domain Name>
EOF
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>
[Network]
DHCP=ipv4
[DHCPv4]
UseDomains=true
EOF
systemctl disable systemd-resolved
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>
# End /etc/resolv.conf
EOF
echo "<lfs>" > /etc/hostname
cat > /etc/hosts << "EOF"
# Begin /etc/hosts
<192.168.0.2> <FQDN> [alias1] [alias2] ...
::1       ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
# End /etc/hosts
EOF
CHROOT_EOF
