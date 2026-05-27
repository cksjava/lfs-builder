#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / kernfs
# Generated from book; do not edit — re-run generate_scripts.py
# kernfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/kernfs"
log_begin
trap 'log_fail $?' ERR

require_var LFS

log_step 1 4 'mkdir -pv $LFS/{dev,proc,sys,run}'
mkdir -pv $LFS/{dev,proc,sys,run}

log_step 2 4 'mount -v --bind /dev $LFS/dev'
mount -v --bind /dev $LFS/dev

log_step 3 4 'mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts'
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

log_step 4 4 'if [ -h $LFS/dev/shm ]; then'
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

trap - ERR
log_done

