#!/bin/bash
# LFS 13.0-systemd — 06-chroot-temp / changingowner
# Generated from book; do not edit — re-run generate_scripts.py
# changingowner
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"

require_var LFS

chown --from lfs -R root:root $LFS/{usr,var,etc,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac
