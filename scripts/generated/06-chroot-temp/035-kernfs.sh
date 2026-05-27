#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / kernfs
# Generated from book; do not edit — re-run generate_scripts.py
# kernfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

mkdir -pv $LFS/{dev,proc,sys,run}
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
