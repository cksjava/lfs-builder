#!/bin/bash
# Create config.site to block host autotools settings (chapter 4).
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
LFS_STEP_ID="04-config-site"
log_begin
trap 'log_fail $?' ERR

require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"
log_step 1 2 "create usr/share directory"
install -d "${LFS}/usr/share"

log_step 2 2 "write config.site"
cat > "${LFS}/usr/share/config.site" <<'EOF'
# config.site for LFS autotools
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF

log "Created ${LFS}/usr/share/config.site"

trap - ERR
log_done
