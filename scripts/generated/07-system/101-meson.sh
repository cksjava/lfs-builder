#!/bin/bash
# LFS 13.0-systemd — 07-system / meson
# Generated from book; do not edit — re-run generate_scripts.py
# meson
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/meson"
log_begin
trap 'log_fail $?; exit 1' ERR

export HOME=/root
export TERM="${TERM:-linux}"
export PS1="(lfs chroot) \u:\w\$ "
export PATH=/usr/bin:/usr/sbin
export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"

# Package: meson
log "enter sources directory"
cd "${LFS_SOURCES:?}"
if [ -d "meson-1.10.1" ]; then
  log "Removing prior meson-1.10.1 tree"
  rm -rf "meson-1.10.1"
fi
log "extract source tarball (if needed)"
TARBALL=$(ls -1 meson-1.10.1*.tar.* 2>/dev/null | head -1)
if [ -z "$TARBALL" ] && [ ! -d "meson-1.10.1" ]; then
  die "Source tarball not found matching meson-1.10.1"
fi
if [ -n "$TARBALL" ] && [ ! -d "meson-1.10.1" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
[ -d "meson-1.10.1" ] || die "Missing source directory meson-1.10.1"
cd "meson-1.10.1"
log "Building in $(pwd)"

log_step 1 2 'pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD'
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

log_step 2 2 'pip3 install --no-index --find-links dist meson'
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd "${LFS_SOURCES:?}"
log "Removing source tree meson-1.10.1"
rm -rf "meson-1.10.1"

trap - ERR
log_done

