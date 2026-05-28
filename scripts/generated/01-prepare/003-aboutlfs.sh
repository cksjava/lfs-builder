#!/bin/bash
# LFS 13.0-systemd — 01-prepare / aboutlfs
# Generated from book; do not edit — re-run generate_scripts.py
# aboutlfs
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="01-prepare/aboutlfs"
log_begin
trap 'log_fail $?; exit 1' ERR

require_var LFS

log_step 1 2 'umask 022'
umask 022

log_step 2 2 'umask'
umask

trap - ERR
log_done

