#!/bin/bash
# Prepare a vanilla Debian/Ubuntu host for LFS 13.0-systemd (chapter 2.2).
#
# Installs packages from data/debian-host-packages.txt, fixes /bin/sh and yacc
# symlinks per the book, then runs ./version-check.sh.
#
# Usage (after clone):
#   ./download-book.sh
#   sudo ./prep.sh
#   ./version-check.sh          # optional repeat as normal user
#   ./build_lfs.py

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PKG_LIST="${ROOT}/data/debian-host-packages.txt"
VC="${ROOT}/version-check.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Prepare a Debian/Ubuntu host for LFS 13.0-systemd (chapter 2.2).

  sudo $0              Install packages, fix symlinks, run version-check.sh
  $0 --help            Show this help

After success, run: ./version-check.sh  then  ./build_lfs.py
EOF
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "prep.sh: re-executing via sudo..."
  exec sudo -E bash "$0" "$@"
fi

if [[ ! -f "$PKG_LIST" ]]; then
  echo "prep.sh: missing package list: $PKG_LIST" >&2
  exit 1
fi
if [[ ! -f "$VC" ]]; then
  echo "prep.sh: missing version-check.sh: $VC" >&2
  exit 1
fi

chmod +x "$VC"

echo "==> Installing LFS chapter 2.2 host packages (Debian/Ubuntu)"
if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  pkgs=$(grep -v '^#' "$PKG_LIST" | grep -v '^[[:space:]]*$' | tr '\n' ' ')
  apt-get update -qq
  apt-get install -y --no-install-recommends $pkgs
elif command -v dnf >/dev/null; then
  echo "==> Installing host packages via dnf"
  dnf install -y gcc gcc-c++ make patch bison flex gawk gettext texinfo \
    wget axel xz perl python3 m4 gperf diffutils findutils binutils coreutils \
    grep gzip sed tar findutils which sudo
elif command -v yum >/dev/null; then
  echo "==> Installing host packages via yum"
  yum install -y gcc gcc-c++ make patch bison flex gawk gettext texinfo \
    wget axel xz perl python3 m4 gperf diffutils findutils binutils coreutils \
    grep gzip sed tar findutils which sudo
else
  echo "prep.sh: no apt-get/dnf/yum found — install chapter 2.2 tools manually" >&2
  exit 1
fi

echo "==> Ensuring /bin/sh uses bash (book requirement)"
if [[ -x /bin/bash ]]; then
  if [[ -x /usr/sbin/update-alternatives ]]; then
    update-alternatives --install /bin/sh sh /bin/bash 100 2>/dev/null || true
    update-alternatives --set sh /bin/bash 2>/dev/null || true
  fi
  if ! sh --version 2>&1 | grep -qi bash; then
    echo "Warning: /bin/sh is not bash — run: sudo ln -sf bash /bin/sh" >&2
  else
    echo "OK: /bin/sh provides bash"
  fi
fi

echo "==> Ensuring /usr/bin/yacc points to bison"
if command -v bison >/dev/null && [[ ! -e /usr/bin/yacc ]]; then
  ln -sf bison /usr/bin/yacc
  echo "OK: created /usr/bin/yacc -> bison"
fi

echo "==> Running version-check.sh"
if ! bash "$VC"; then
  echo "prep.sh: host still does not meet LFS requirements (see above)" >&2
  exit 1
fi

echo ""
echo "Host preparation complete. You can start the build with:"
echo "  ./build_lfs.py"
