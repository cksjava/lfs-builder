#!/bin/bash
# LFS 13.0-systemd — 04-cross-toolchain / linux-headers
# Generated from book; do not edit — re-run generate_scripts.py
# linux-headers
# RUN_AS: lfs
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
