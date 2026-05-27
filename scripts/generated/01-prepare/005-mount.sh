#!/bin/bash
# LFS 13.0-systemd — 01-prepare / mount
# Generated from book; do not edit — re-run generate_scripts.py
# mounting
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

chown root:root $LFS
chmod 755 $LFS
/sbin/swapon -v "$LFS_DEVICE"
