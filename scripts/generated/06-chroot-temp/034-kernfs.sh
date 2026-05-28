#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / kernfs
# Generated from book; do not edit — re-run generate_scripts.py
# kernfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/kernfs"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

log_step 1 4 'mkdir -pv $LFS/{dev,proc,sys,run}'
mkdir -pv $LFS/{dev,proc,sys,run}

log_step 2 4 'mountpoint -q $LFS/dev 2>/dev/null || mount -v --bind /dev $LFS/dev'
mountpoint -q $LFS/dev 2>/dev/null || mount -v --bind /dev $LFS/dev

log_step 3 4 'mountpoint -q $LFS/dev/pts 2>/dev/null || mount -vt devpts devpts -o ...'
mountpoint -q $LFS/dev/pts 2>/dev/null || mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mountpoint -q $LFS/proc 2>/dev/null || mount -vt proc proc $LFS/proc
mountpoint -q $LFS/sys 2>/dev/null || mount -vt sysfs sysfs $LFS/sys
mountpoint -q $LFS/run 2>/dev/null || mount -vt tmpfs tmpfs $LFS/run

log_step 4 4 'if [ -h $LFS/dev/shm ]; then'
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
mountpoint -q $LFS/dev/shm 2>/dev/null || mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

trap - ERR
log_done

