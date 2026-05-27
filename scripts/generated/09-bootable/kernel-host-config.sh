#!/bin/bash
# Seed kernel .config from host — invoked by orchestrator before 0NN-kernel.sh
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="09-bootable/kernel-host-config"
log_begin
trap 'log_fail $?' ERR

require_var LFS_SOURCES
log_step 1 4 "locate Linux source tree"
LINUX_DIR=$(ls -d "${LFS_SOURCES}"/linux-* 2>/dev/null | head -1)
if [ -z "$LINUX_DIR" ]; then
  die "Linux source tree not found in ${LFS_SOURCES}"
fi
cd "$LINUX_DIR"
log "Using ${LINUX_DIR}"

log_step 2 4 "copy host kernel config"
HOST_CFG=""
for c in "/boot/config-$(uname -r)" /proc/config.gz /boot/config; do
  [ -e "$c" ] && HOST_CFG=$c && break
done
if [ -z "$HOST_CFG" ]; then
  die "No host kernel config found; run make defconfig manually"
fi
log "Host config: $HOST_CFG"
if [[ "$HOST_CFG" == *.gz ]]; then
  zcat "$HOST_CFG" > .config
else
  cp "$HOST_CFG" .config
fi

log_step 3 4 "apply olddefconfig"
make olddefconfig

log_step 4 4 "enable LFS mandatory kernel options"
if [ -x scripts/config ]; then
  scripts/config --disable WERROR --enable CGROUPS --enable MEMCG \
    --enable INOTIFY_USER --enable SIGNALFD --enable TIMERFD --enable EPOLL \
    --enable TMPFS --enable TMPFS_POSIX_ACL --enable DEVTMPFS \
    --enable DEVTMPFS_MOUNT --disable UEVENT_HELPER --enable NET \
    --enable INET --enable IPV6 --enable PSI || true
  make olddefconfig
fi

trap - ERR
log_done
