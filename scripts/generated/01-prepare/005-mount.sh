#!/bin/bash
# LFS 13.0-systemd — 01-prepare / mount
# Generated from book; do not edit — re-run generate_scripts.py
# mounting
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS
[ -d "${LFS}" ] || die "LFS not mounted — run partition step first"
chown root:root "${LFS}" 2>/dev/null || true
chmod 755 "${LFS}"
