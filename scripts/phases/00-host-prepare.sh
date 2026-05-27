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

ROOT="$(cd "${LFS_BUILDER_SCRIPTS:?}/.." && pwd)"
log_step 1 1 "run prep.sh (chapter 2.2 host preparation)"
if ! bash "${ROOT}/prep.sh"; then
  die "Host preparation failed (see prep.sh output)"
fi

trap - ERR
log_done
