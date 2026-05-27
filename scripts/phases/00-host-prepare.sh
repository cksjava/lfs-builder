#!/bin/bash
# Install host packages and fix symlinks required by LFS chapter 2.2 (Debian/Ubuntu).
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="00-host-prepare"
log_begin
trap 'log_fail $?' ERR

require_root

if [[ "${LFS_SKIP_HOST_PREPARE:-0}" == "1" ]]; then
  log "LFS_SKIP_HOST_PREPARE=1 — skipping host package installation"
  trap - ERR
  log_done
  exit 0
fi

log_step 1 4 "install distribution build dependencies"
list="${LFS_BUILDER_SCRIPTS:?}/../data/debian-host-packages.txt"
if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  pkgs=$(grep -v '^#' "$list" | grep -v '^[[:space:]]*$' | tr '\n' ' ')
  log "apt-get install: ${pkgs}"
  apt-get update -qq
  apt-get install -y --no-install-recommends $pkgs
elif command -v dnf >/dev/null; then
  log "Installing host packages via dnf (subset of Debian list)"
  dnf install -y gcc gcc-c++ make patch bison flex gawk gettext texinfo \
    wget xz perl python3 m4 gperf diffutils findutils
elif command -v yum >/dev/null; then
  yum install -y gcc gcc-c++ make patch bison flex gawk gettext texinfo \
    wget xz perl python3 m4 gperf diffutils findutils
else
  log "Warning: no apt-get/dnf/yum — install chapter 2.2 packages manually"
fi

log_step 2 4 "ensure /bin/sh uses bash (book requirement)"
if [ -x /bin/bash ]; then
  if [ -x /usr/sbin/update-alternatives ]; then
    update-alternatives --install /bin/sh sh /bin/bash 100 2>/dev/null || true
    update-alternatives --set sh /bin/bash 2>/dev/null || true
  fi
  if ! sh --version 2>&1 | grep -qi bash; then
    log "Warning: /bin/sh is not bash — version-check may fail; fix manually"
  else
    log "/bin/sh provides bash"
  fi
fi

log_step 3 4 "ensure yacc points to bison"
if command -v bison >/dev/null && [ ! -e /usr/bin/yacc ]; then
  ln -sf bison /usr/bin/yacc
  log "Created /usr/bin/yacc -> bison"
fi

log_step 4 4 "re-run version check after prepare"
vc="${LFS_BUILDER_SCRIPTS:?}/../data/version-check.sh"
bash "$vc" || die "Host still missing requirements after prepare"

trap - ERR
log_done
