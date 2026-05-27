#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
LFS_STEP_ID="02-sources-dir"
log_begin
trap 'log_fail $?' ERR

require_root
require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"
log_step 1 2 "create sources directory"
mkdir -pv "${LFS}/sources"
log_step 2 2 "set sources directory permissions"
chmod a+wt "${LFS}/sources"
log "Sources directory: ${LFS}/sources"

trap - ERR
log_done
