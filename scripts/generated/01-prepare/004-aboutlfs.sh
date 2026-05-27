#!/bin/bash
# LFS 13.0-systemd — 01-prepare / aboutlfs
# Generated from book; do not edit — re-run generate_scripts.py
# aboutlfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

umask 022
umask
