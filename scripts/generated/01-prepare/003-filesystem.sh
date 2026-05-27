#!/bin/bash
# LFS 13.0-systemd — 01-prepare / filesystem
# Generated from book; do not edit — re-run generate_scripts.py
# creatingfilesystem
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

mkfs -v -t ext4 "$LFS_DEVICE"
mkswap "$LFS_DEVICE"
