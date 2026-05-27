#!/bin/bash
# LFS 13.0-systemd — 01-prepare / filesystem
# Generated from book; do not edit — re-run generate_scripts.py
# creatingfilesystem
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
LFS_STEP_ID="01-prepare/filesystem"
log_begin
trap 'log_fail $?' ERR

log "Skipping: partition formatted by 01-partition.sh"
trap - ERR
log_done

