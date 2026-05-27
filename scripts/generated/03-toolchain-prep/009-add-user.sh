#!/bin/bash
# LFS 13.0-systemd — 03-toolchain-prep / add-user
# Generated from book; do not edit — re-run generate_scripts.py
# addinguser
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac
