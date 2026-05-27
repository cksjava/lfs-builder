#!/bin/bash
# LFS 13.0-systemd — 07-system / vim
# Generated from book; do not edit — re-run generate_scripts.py
# vim
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: vim
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 vim-9.2.0078*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "vim-9.2.0078" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "vim-9.2.0078"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
chown -R tester .
sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak
su tester -c "TERM=xterm-256color LANG="$LFS_LANG" make -j1 test" \
   &> vim-test.log
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.0078
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif
" End /etc/vimrc
EOF
vim -c ':options'
CHROOT_EOF
