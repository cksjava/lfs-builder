#!/bin/bash
# LFS 13.0-systemd — 03-toolchain-prep / min-layout
# Generated from book; do not edit — re-run generate_scripts.py
# creatingminlayout
set -euo pipefail
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="03-toolchain-prep/min-layout"
log_begin
trap 'log_fail $?' ERR

require_var LFS

log_step 1 4 'mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}'
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

log_step 2 4 'for i in bin lib sbin; do'
for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

log_step 3 4 'case $(uname -m) in'
case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

log_step 4 4 'mkdir -pv $LFS/tools'
mkdir -pv $LFS/tools

trap - ERR
log_done

