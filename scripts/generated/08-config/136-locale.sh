#!/bin/bash
# LFS 13.0-systemd — 08-config / locale
# Generated from book; do not edit — re-run generate_scripts.py
# locale
# RUN_IN_CHROOT: yes
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="08-config/locale"
log_begin
trap 'log_fail $?' ERR

require_var LFS
log "entering chroot at ${LFS}"
chroot "${LFS}" /usr/bin/env -i \
    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \u:\w\$ " \
    PATH=/usr/bin:/usr/sbin \
    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \
    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \
    /bin/bash -euo pipefail <<'CHROOT_EOF'
log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }

log_step 1 11 'locale -a'
locale -a

log_step 2 11 'LC_ALL=<locale name> locale charmap'
LC_ALL=<locale name> locale charmap

log_step 3 11 'LC_ALL=<locale name> locale language'
LC_ALL=<locale name> locale language
LC_ALL=<locale name> locale charmap
LC_ALL=<locale name> locale int_curr_symbol
LC_ALL=<locale name> locale int_prefix

log_step 4 11 'write configuration file'
cat > /etc/locale.conf << "EOF"
LANG=<ll>_<CC>.<charmap><@modifiers>
EOF

log_step 5 11 'write configuration file'
cat > /etc/profile << "EOF"
# Begin /etc/profile

log_step 6 11 'for i in $(locale); do'
for i in $(locale); do
  unset ${i%=*}
done

log_step 7 11 'if [[ "$TERM" = linux ]]; then'
if [[ "$TERM" = linux ]]; then
  export LANG="$LFS_LANG"
else
  source /etc/locale.conf

log_step 8 11 'for i in $(locale); do'
for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

log_step 9 11 '# End /etc/profile'
# End /etc/profile
EOF

log_step 10 11 'localectl set-locale LANG="<ll>_<CC>.<charmap><@modifiers>"'
localectl set-locale LANG="<ll>_<CC>.<charmap><@modifiers>"

log_step 11 11 'localectl set-locale LANG="en_US.UTF-8" LC_CTYPE="en_US"'
localectl set-locale LANG="en_US.UTF-8" LC_CTYPE="en_US"

CHROOT_EOF
log "left chroot"
trap - ERR
log_done

