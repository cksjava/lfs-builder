#!/bin/bash
# LFS 13.0-systemd — 03-toolchain-prep / min-layout
# Generated from book; do not edit — re-run generate_scripts.py
# creatingminlayout
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac
mkdir -pv $LFS/tools
