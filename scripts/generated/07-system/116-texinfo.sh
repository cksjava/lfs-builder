#!/bin/bash
# LFS 13.0-systemd — 07-system / texinfo
# Generated from book; do not edit — re-run generate_scripts.py
# texinfo
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/texinfo"
log_begin
trap 'log_fail $?' ERR

# Package: texinfo
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "texinfo-7.2" ]; then
  log "Removing prior texinfo-7.2 tree"
  rm -rf "texinfo-7.2"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 texinfo-7.2*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "texinfo-7.2" ]; then
  die "Source tarball not found matching texinfo-7.2"
fi
if [ -n "$TARBALL" ] && [ ! -d "texinfo-7.2" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "texinfo-7.2" ] || die "Missing source directory texinfo-7.2"
cd "texinfo-7.2"
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

log_step 1 7 'sed '"'"'s/! $output_file eq/$output_file ne/'"'"' -i tp/Texinfo/Convert/*.pm'
sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm

log_step 2 7 'configure'
./configure --prefix=/usr

log_step 3 7 'make'
make

log_step 4 7 'make check (test suite)'
if [[ "${LFS_RUN_TESTS:-0}" == "1" ]]; then
  make check
else
  log "skipping test suite (LFS_RUN_TESTS=0)"
fi

log_step 5 7 'make install'
make install

log_step 6 7 'make'
make TEXMF=/usr/share/texmf install-tex

log_step 7 7 'pushd /usr/share/info'
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd

CHROOT_EOF
log "left chroot"
cd "${LFS_SOURCES:?}"
log "Removing source tree texinfo-7.2"
rm -rf "texinfo-7.2"

trap - ERR
log_done

