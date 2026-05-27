#!/bin/bash
# LFS 13.0-systemd — 07-system / texinfo
# Generated from book; do not edit — re-run generate_scripts.py
# texinfo
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

# Package: texinfo
cd "${LFS_SOURCES:?}"
TARBALL=$(ls -1 texinfo-7.2*.tar.* 2>/dev/null | head -1)
if [ -n "$TARBALL" ] && [ ! -d "texinfo-7.2" ]; then
  echo "Extracting $TARBALL..."
  tar -xf "$TARBALL"
fi
cd "texinfo-7.2"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm
./configure --prefix=/usr
make
make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd
CHROOT_EOF
