#!/bin/bash
# LFS 13.0-systemd — 07-system / glibc
# Generated from book; do not edit — re-run generate_scripts.py
# glibc
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/glibc"
log_begin
trap 'log_fail $?' ERR

# Package: glibc
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 glibc-2.43*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "glibc-2.43" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "glibc-2.43"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 32 'apply patch'
patch -Np1 -i ../glibc-fhs-1.patch

log_step 2 32 'mkdir -v build'
mkdir -v build
cd       build

log_step 3 32 'echo "rootsbindir=/usr/sbin" > configparms'
echo "rootsbindir=/usr/sbin" > configparms

log_step 4 32 'configure'
../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.4

log_step 5 32 'make'
make

log_step 6 32 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 7 32 'grep "Timed out" $(find -name \*.out)'
grep "Timed out" $(find -name \*.out)

log_step 8 32 'touch /etc/ld.so.conf'
touch /etc/ld.so.conf

log_step 9 32 'sed '"'"'/test-installation/s@$(PERL)@echo not running@'"'"' -i ../Makefile'
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

log_step 10 32 'rm -f /usr/sbin/nscd'
rm -f /usr/sbin/nscd

log_step 11 32 'systemctl disable --now nscd'
systemctl disable --now nscd

log_step 12 32 'make'
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/*.so.* /usr/lib

log_step 13 32 'DIR=$(dirname $(gcc -print-libgcc-file-name))'
DIR=$(dirname $(gcc -print-libgcc-file-name))
[ -e $DIR/include/limits.h ]    || mv $DIR/include{-fixed,}/limits.h
[ -e $DIR/include/syslimits.h ] || mv $DIR/include{-fixed,}/syslimits.h
rm -rfv $DIR/include-fixed/*
unset DIR

log_step 14 32 'make install'
make install

log_step 15 32 'sed '"'"'/RTLDLIST=/s@/usr@@g'"'"' -i /usr/bin/ldd'
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

log_step 16 32 'localedef -i C -f UTF-8 C.UTF-8'
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

log_step 17 32 'make'
make localedata/install-locales

log_step 18 32 'write configuration file'
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

log_step 19 32 'passwd: files systemd'
passwd: files systemd
group: files systemd
shadow: files systemd

log_step 20 32 'hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns'
hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

log_step 21 32 'protocols: files'
protocols: files
services: files
ethers: files
rpc: files

log_step 22 32 '# End /etc/nsswitch.conf'
# End /etc/nsswitch.conf
EOF

log_step 23 32 'extract source archive'
tar -xf ../../tzdata2025c.tar.gz

log_step 24 32 'ZONEINFO=/usr/share/zoneinfo'
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

log_step 25 32 'for tz in etcetera southamerica northamerica europe africa antarctica  \'
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

log_step 26 32 'cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO'
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz

log_step 27 32 'tzselect'
tzselect

log_step 28 32 'ln -sfv /usr/share/zoneinfo/"${LFS_DEVICE#/dev/}" /etc/localtime'
ln -sfv /usr/share/zoneinfo/"${LFS_DEVICE#/dev/}" /etc/localtime

log_step 29 32 'write configuration file'
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

log_step 30 32 'EOF'
EOF

log_step 31 32 'write configuration file'
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

log_step 32 32 'EOF'
EOF
mkdir -pv /etc/ld.so.conf.d

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

