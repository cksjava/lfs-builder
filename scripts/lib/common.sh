#!/bin/bash
# Shared helpers for LFS build phase scripts.
set -euo pipefail

# Step id for log prefixes (set by generated scripts or derived from script name)
: "${LFS_STEP_ID:=$(basename "${0}" .sh)}"

log() {
  echo "[lfs $(date +%H:%M:%S)] [$LFS_STEP_ID] $*"
}

log_begin() {
  log "=== BEGIN ==="
}

log_done() {
  log "=== DONE ==="
}

log_fail() {
  local rc="${1:-$?}"
  log "=== FAILED (exit ${rc}) ===" >&2
}

# log_step <n> <total> <description>
log_step() {
  local n=$1 total=$2
  shift 2
  log "[$n/${total}] $*"
}

die() {
  local msg=$1
  local rc=${2:-1}
  log_fail "$rc"
  echo "[lfs] ERROR: ${msg}" >&2
  exit "$rc"
}

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "Must run as root"
}

require_var() {
  local name="$1"
  [[ -n "${!name:-}" ]] || die "Required variable $name is not set"
}

# Minimal logging inside chroot heredocs (no access to this file)
CHROOT_LOG_INIT='log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }'
