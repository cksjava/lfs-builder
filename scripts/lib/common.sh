#!/bin/bash
# Shared helpers for LFS build phase scripts.
set -euo pipefail

log() { echo "[lfs] $*"; }
die() { echo "[lfs] ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "Must run as root"
}

require_var() {
  local name="$1"
  [[ -n "${!name:-}" ]] || die "Required variable $name is not set"
}
