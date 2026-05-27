#!/bin/bash
# LFS 13.0-systemd — 07-system / vim
# Generated from book; do not edit — re-run generate_scripts.py
# vim
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="07-system/vim"
log_begin
trap 'log_fail $?' ERR

# Package: vim
log "enter sources directory"
cd "${LFS_SOURCES:?}"
log "extract source tarball (if needed)"
TARBALL=$(ls -1 vim-9.2.0078*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "vim-9.2.0078" ]; then
  log "Extracting $TARBALL"
  tar -xf "$TARBALL"
fi
cd "vim-9.2.0078"
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

log_step 1 13 'echo '"'"'#define SYS_VIMRC_FILE "/etc/vimrc"'"'"' >> src/feature.h'
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

log_step 2 13 'configure'
./configure --prefix=/usr

log_step 3 13 'make'
make

log_step 4 13 'chown -R tester .'
chown -R tester .
sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak

log_step 5 13 'su tester -c "TERM=xterm-256color LANG="$LFS_LANG" make -j1 test" \'
su tester -c "TERM=xterm-256color LANG="$LFS_LANG" make -j1 test" \
   &> vim-test.log

log_step 6 13 'make install'
make install

log_step 7 13 'ln -sv vim /usr/bin/vi'
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

log_step 8 13 'ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.0078'
ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.0078

log_step 9 13 'write configuration file'
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

log_step 10 13 '" Ensure defaults are set before customizing settings, not after'
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

log_step 11 13 'set nocompatible'
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

log_step 12 13 '" End /etc/vimrc'
" End /etc/vimrc
EOF

log_step 13 13 'vim -c '"'"':options'"'"''
vim -c ':options'

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

