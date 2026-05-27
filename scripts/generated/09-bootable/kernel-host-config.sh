#!/bin/bash
# Seed kernel .config from host — invoked by orchestrator before 0NN-kernel.sh
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
require_var LFS_SOURCES
LINUX_DIR=$(ls -d "${LFS_SOURCES}"/linux-* 2>/dev/null | head -1)
if [ -z "$LINUX_DIR" ]; then
  echo "Linux source tree not found in ${LFS_SOURCES}" >&2
  exit 1
fi
cd "$LINUX_DIR"
HOST_CFG=""
for c in "/boot/config-$(uname -r)" /proc/config.gz /boot/config; do
  [ -e "$c" ] && HOST_CFG=$c && break
done
if [ -n "$HOST_CFG" ]; then
  echo "Using host config: $HOST_CFG"
  if [[ "$HOST_CFG" == *.gz ]]; then
    zcat "$HOST_CFG" > .config
  else
    cp "$HOST_CFG" .config
  fi
  make olddefconfig
  if [ -x scripts/config ]; then
    scripts/config --disable WERROR --enable CGROUPS --enable MEMCG \
      --enable INOTIFY_USER --enable SIGNALFD --enable TIMERFD --enable EPOLL \
      --enable TMPFS --enable TMPFS_POSIX_ACL --enable DEVTMPFS \
      --enable DEVTMPFS_MOUNT --disable UEVENT_HELPER --enable NET \
      --enable INET --enable IPV6 --enable PSI || true
    make olddefconfig
  fi
else
  echo "No host kernel config found; run make defconfig manually" >&2
  exit 1
fi
