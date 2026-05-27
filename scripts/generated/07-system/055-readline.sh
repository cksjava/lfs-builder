#!/bin/bash
# LFS 13.0-systemd — 07-system / readline
# Generated from book; do not edit — re-run generate_scripts.py
# readline
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="07-system/readline"
log_begin
trap 'log_fail $?' ERR

# Package: readline
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 readline-8.3*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "readline-8.3" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "readline-8.3"
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

log_step 1 7 'sed -i '"'"'/MV.*old/d'"'"' Makefile.in'
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

log_step 2 7 'sed -i '"'"'s/-Wl,-rpath,[^ ]*//'"'"' support/shobj-conf'
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

log_step 3 7 'sed -e '"'"'270a\'
sed -e '270a\
     else\
       chars_avail = 1;'      \
    -e '288i\   result = -1;' \
    -i.orig input.c

log_step 4 7 'configure'
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.3

log_step 5 7 'make'
make SHLIB_LIBS="-lncursesw"

log_step 6 7 'make install'
make install

log_step 7 7 'install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3'
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

