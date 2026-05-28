#!/bin/bash
# LFS 13.0-systemd — 08-config / inputrc
# Generated from book; do not edit — re-run generate_scripts.py
# inputrc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/inputrc"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

log_step 1 11 'write configuration file'
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

log_step 2 11 '# Allow the command prompt to wrap to the next line'
# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

log_step 3 11 '# Enable 8-bit input'
# Enable 8-bit input
set meta-flag On
set input-meta On

log_step 4 11 '# Turns off 8th bit stripping'
# Turns off 8th bit stripping
set convert-meta Off

log_step 5 11 '# Keep the 8th bit for display'
# Keep the 8th bit for display
set output-meta On

log_step 6 11 '# none, visible or audible'
# none, visible or audible
set bell-style none

log_step 7 11 '# All of the following map the escape sequence of the value'
# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

log_step 8 11 '# for linux console'
# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

log_step 9 11 '# for xterm'
# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

log_step 10 11 '# for Konsole'
# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

log_step 11 11 '# End /etc/inputrc'
# End /etc/inputrc
EOF

trap - ERR
log_done

