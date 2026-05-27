#!/bin/bash
# LFS 13.0-systemd — 08-config / locale
# Generated from book; do not edit — re-run generate_scripts.py
# locale
# RUN_IN_CHROOT: yes
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
locale -a
LC_ALL=<locale name> locale charmap
LC_ALL=<locale name> locale language
LC_ALL=<locale name> locale charmap
LC_ALL=<locale name> locale int_curr_symbol
LC_ALL=<locale name> locale int_prefix
cat > /etc/locale.conf << "EOF"
LANG=<ll>_<CC>.<charmap><@modifiers>
EOF
cat > /etc/profile << "EOF"
# Begin /etc/profile
for i in $(locale); do
  unset ${i%=*}
done
if [[ "$TERM" = linux ]]; then
  export LANG="$LFS_LANG"
else
  source /etc/locale.conf
for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi
# End /etc/profile
EOF
localectl set-locale LANG="<ll>_<CC>.<charmap><@modifiers>"
localectl set-locale LANG="en_US.UTF-8" LC_CTYPE="en_US"
CHROOT_EOF
