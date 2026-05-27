#!/bin/bash
# Create config.site to block host autotools settings (chapter 4).
source "$(dirname "$0")/../lib/common.sh"
require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"
install -d "${LFS}/usr/share"

cat > "${LFS}/usr/share/config.site" <<'EOF'
# config.site for LFS autotools
ac_cv_func_malloc_0_nonnull=yes
ac_cv_func_realloc_0_nonnull=yes
EOF

log "Created ${LFS}/usr/share/config.site"
