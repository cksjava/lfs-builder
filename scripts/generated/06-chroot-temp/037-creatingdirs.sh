#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / creatingdirs
# Generated from book; do not edit — re-run generate_scripts.py
# creatingdirs
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="06-chroot-temp/creatingdirs"
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

log_step 1 4 'mkdir -pv /{boot,home,mnt,opt,srv}'
mkdir -pv /{boot,home,mnt,opt,srv}

log_step 2 4 'mkdir -pv /etc/{opt,sysconfig}'
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

log_step 3 4 'ln -sfv /run /var/run'
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

log_step 4 4 'install -dv -m 0750 /root'
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

