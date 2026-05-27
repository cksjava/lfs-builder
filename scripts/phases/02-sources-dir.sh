#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
require_root
require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"
mkdir -pv "${LFS}/sources"
chmod a+wt "${LFS}/sources"
log "Sources directory: ${LFS}/sources"
