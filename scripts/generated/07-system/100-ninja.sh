#!/bin/bash
# LFS 13.0-systemd — 07-system / ninja
# Generated from book; do not edit — re-run generate_scripts.py
# ninja
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/ninja"
log_begin
trap 'log_fail $?' ERR

# Package: ninja
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "ninja-1.13.2" ]; then
  log "Removing prior ninja-1.13.2 tree"
  rm -rf "ninja-1.13.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 ninja-1.13.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "ninja-1.13.2" ]; then
  die "Source tarball not found matching ninja-1.13.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "ninja-1.13.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "ninja-1.13.2" ] || die "Missing source directory ninja-1.13.2"
cd "ninja-1.13.2"
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

log_step 1 3 'sed -i '"'"'/int Guess/a \'
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

log_step 2 3 'python3 configure.py --bootstrap --verbose'
python3 configure.py --bootstrap --verbose

log_step 3 3 'install -vm755 ninja /usr/bin/'
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree ninja-1.13.2"
rm -rf "ninja-1.13.2"

trap - ERR
log_done

