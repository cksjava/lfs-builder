#!/bin/bash
# Verify host meets LFS 13.0-systemd chapter 2.2 requirements (before partitioning).
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="00-host-check"
log_begin
trap 'log_fail $?' ERR

require_root

log_step 1 3 "check recommended hardware"
cores=$(nproc 2>/dev/null || echo 0)
mem_kb=$(grep -E '^MemTotal:' /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)
mem_gb=$((mem_kb / 1024 / 1024))
if [ "$cores" -lt 4 ]; then
  log "Warning: book recommends at least 4 CPU cores (found ${cores})"
fi
if [ "$mem_gb" -lt 8 ]; then
  log "Warning: book recommends at least 8 GB RAM (found ~${mem_gb} GB)"
fi

log_step 2 3 "run LFS version-check.sh"
vc="${LFS_BUILDER_SCRIPTS:?}/../data/version-check.sh"
if [ ! -x "$vc" ]; then
  chmod +x "$vc" 2>/dev/null || true
fi
if ! bash "$vc"; then
  die "Host does not meet LFS tool version requirements (see output above)"
fi

log_step 3 3 "summary"
log "Host system satisfies LFS chapter 2.2 software requirements"

trap - ERR
log_done
