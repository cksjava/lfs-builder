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

# Idempotent helpers (safe when resuming a partial build)
ensure_group() {
  local name=$1
  shift || true
  if getent group "$name" &>/dev/null; then
    log "group ${name} already exists"
    return 0
  fi
  groupadd "$name" "$@"
}

# ensure_user: pass useradd args with username as the LAST argument
ensure_user() {
  local name=${!#}
  if getent passwd "$name" &>/dev/null; then
    log "user ${name} already exists"
    return 0
  fi
  useradd "$@"
}

safe_mount() {
  local target=$1
  shift
  if mountpoint -q "$target" 2>/dev/null; then
    log "already mounted: ${target}"
    return 0
  fi
  mount "$@" "$target"
}

# Minimal logging inside chroot heredocs (no access to this file)
CHROOT_LOG_INIT='log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }'
