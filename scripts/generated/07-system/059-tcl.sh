#!/bin/bash
# LFS 13.0-systemd — 07-system / tcl
# Generated from book; do not edit — re-run generate_scripts.py
# tcl
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/tcl"
log_begin
trap 'log_fail $?' ERR

# Package: tcl
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "tcl8.6.17" ]; then
  log "Removing prior tcl8.6.17 tree"
  rm -rf "tcl8.6.17"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 tcl8.6.17-src*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "tcl8.6.17" ]; then
  die "Source tarball not found matching tcl8.6.17-src"
fi
if [ -n "$TARBALL" ] && [ ! -d "tcl8.6.17" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "tcl8.6.17" ] || die "Missing source directory tcl8.6.17"
cd "tcl8.6.17"
log "Building in $(pwd)"

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /bin/bash -euo pipefail <<'CHROOT_EOF'
export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"

log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 13 'configure'
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath

log_step 2 13 'make'
make

log_step 3 13 'sed -e "s|$SRCDIR/unix|/usr/lib|" \'
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

log_step 4 13 'sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.12|/usr/lib/tdbc1.1.12|" \'
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.12|/usr/lib/tdbc1.1.12|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12/generic|/usr/include|"     \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12/library|/usr/lib/tcl8.6|"  \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12|/usr/include|"             \
    -i pkgs/tdbc1.1.12/tdbcConfig.sh

log_step 5 13 'sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.4|/usr/lib/itcl4.3.4|" \'
sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.4|/usr/lib/itcl4.3.4|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.4/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.4|/usr/include|"            \
    -i pkgs/itcl4.3.4/itclConfig.sh

log_step 6 13 'unset SRCDIR'
unset SRCDIR

log_step 7 13 'LC_ALL=C.UTF-8 make test'
LC_ALL=C.UTF-8 make test

log_step 8 13 'make install'
make install 
chmod 644 /usr/lib/libtclstub8.6.a

log_step 9 13 'chmod -v u+w /usr/lib/libtcl8.6.so'
chmod -v u+w /usr/lib/libtcl8.6.so

log_step 10 13 'make install'
make install-private-headers

log_step 11 13 'ln -sfv tclsh8.6 /usr/bin/tclsh'
ln -sfv tclsh8.6 /usr/bin/tclsh

log_step 12 13 'mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3'
mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3

log_step 13 13 'extract source archive'
cd ..
tar -xf ../tcl8.6.17-html.tar.gz --strip-components=1
mkdir -vp -p /usr/share/doc/tcl-8.6.17
cp -v -r  ./html/* /usr/share/doc/tcl-8.6.17

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree tcl8.6.17"
rm -rf "tcl8.6.17"

trap - ERR
log_done

