#!/bin/bash
# LFS 13.0-systemd — 07-system / sqlite
# Generated from book; do not edit — re-run generate_scripts.py
# sqlite
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/sqlite"
log_begin
trap 'log_fail $?' ERR

# Package: sqlite
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 sqlite-3510200*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "sqlite-3510200" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "sqlite-3510200"
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

log_step 1 5 'extract source archive'
tar -xf ../sqlite-doc-3510200.tar.xz

log_step 2 5 'configure'
./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -D SQLITE_SECURE_DELETE=1"

log_step 3 5 'make'
make LDFLAGS.rpath=""

log_step 4 5 'make install'
make install

log_step 5 5 'install -v -m755 -d /usr/share/doc/sqlite-3.51.2'
install -v -m755 -d /usr/share/doc/sqlite-3.51.2
cp -v -R sqlite-doc-3510200/* /usr/share/doc/sqlite-3.51.2

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

