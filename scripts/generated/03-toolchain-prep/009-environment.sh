#!/bin/bash
# LFS 13.0-systemd — 03-toolchain-prep / environment
# Generated from book; do not edit — re-run generate_scripts.py
# settingenvironment
# RUN_AS: lfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="03-toolchain-prep/environment"
log_begin
trap 'log_fail $?' ERR

require_var LFS

log_step 1 3 'write configuration file'
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

log_step 2 3 'write configuration file'
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS="$LFS"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

log_step 3 3 'write configuration file'
cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF

trap - ERR
log_done

