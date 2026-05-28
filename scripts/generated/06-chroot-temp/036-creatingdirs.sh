#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / creatingdirs
# Generated from book; do not edit — re-run generate_scripts.py
# creatingdirs
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="06-chroot-temp/creatingdirs"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"
if [ -z "${COMPILER_PATH:-}" ]; then
  _cc1=$(find /usr/libexec/gcc /usr/lib/gcc /tools/libexec/gcc \
    -name cc1 -type f 2>/dev/null | head -1)
  [ -n "$_cc1" ] && export COMPILER_PATH="$(dirname "$_cc1")"
fi

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

trap - ERR
log_done

