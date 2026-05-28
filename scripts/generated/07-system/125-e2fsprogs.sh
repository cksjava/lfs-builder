#!/bin/bash
# LFS 13.0-systemd — 07-system / e2fsprogs
# Generated from book; do not edit — re-run generate_scripts.py
# e2fsprogs
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/e2fsprogs"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: e2fsprogs
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "e2fsprogs-1.47.3" ]; then
  log "Removing prior e2fsprogs-1.47.3 tree"
  rm -rf "e2fsprogs-1.47.3"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 e2fsprogs-1.47.3*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "e2fsprogs-1.47.3" ]; then
  die "Source tarball not found matching e2fsprogs-1.47.3"
fi
if [ -n "$TARBALL" ] && [ ! -d "e2fsprogs-1.47.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "e2fsprogs-1.47.3" ] || die "Missing source directory e2fsprogs-1.47.3"
cd "e2fsprogs-1.47.3"
log "Building in $(pwd)"

log_step 1 9 'mkdir -vp build'
mkdir -vp build
cd       build

log_step 2 9 'configure'
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck

log_step 3 9 'make'
make

log_step 4 9 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 9 'make install'
make install

log_step 6 9 'rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a'
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

log_step 7 9 'gunzip -v /usr/share/info/libext2fs.info.gz'
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

log_step 8 9 'makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo'
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

log_step 9 9 'sed '"'"'s/metadata_csum_seed,//'"'"' -i /etc/mke2fs.conf'
sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf

cd "${LFS_SOURCES:?}"
log "Removing source tree e2fsprogs-1.47.3"
rm -rf "e2fsprogs-1.47.3"

trap - ERR
log_done

