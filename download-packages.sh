#!/bin/bash
# Download and extract lfs-packages-VERSION.tar (all sources + patches).
#
# Version defaults from ../13.0/ (book directory name or index.html).
#
# Usage:
#   ./download-packages.sh
#   ./download-packages.sh --dest /mnt/lfs/sources
#   ./download-packages.sh --version 13.0 --dest ./package-cache

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib/lfs-packages.sh
source "${ROOT}/scripts/lib/lfs-packages.sh"

DEFAULT_BOOK="$(cd "${ROOT}/.." && pwd)/13.0"
DEFAULT_DEST="$(cd "${ROOT}/.." && pwd)/sources-cache"
BOOK="${DEFAULT_BOOK}"
DEST=""
VERSION=""
FORCE=0

usage() {
  cat <<EOF
Download LFS sources and patches in one tarball (lfs-packages-VERSION.tar) via axel (100 connections).

  $0                         Download to ../sources-cache/ (version from ../13.0/)
  $0 --dest DIR              Extract packages into DIR
  $0 --book PATH             Book tree to read version from (default: ${DEFAULT_BOOK})
  $0 --version VER           Book version, e.g. 13.0 (overrides --book)
  $0 --force                 Re-download even if tarball is cached
  $0 --wget-list             Use per-URL wget instead of the tarball
  $0 --help                  Show this help

Example (before build, into LFS sources):
  sudo mkdir -p /mnt/lfs/sources
  sudo $0 --dest /mnt/lfs/sources --book ../13.0
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -d|--dest)
      DEST="$(cd "$2" && pwd)"
      shift 2
      ;;
    --book)
      BOOK="$(cd "$2" && pwd)"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --wget-list)
      export LFS_USE_WGET_LIST=1
      shift
      ;;
    *)
      echo "$0: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${DEST}" ]]; then
  mkdir -p "${DEFAULT_DEST}"
  DEST="$(cd "${DEFAULT_DEST}" && pwd)"
fi

export LFS_BOOK="${BOOK}"
if [[ -z "${VERSION}" ]]; then
  if [[ -d "${BOOK}" ]]; then
    VERSION="$(lfs_packages_version)"
  else
    echo "$0: book not found at ${BOOK}; use --version or ./download-book.sh" >&2
    exit 1
  fi
fi
export LFS_BOOK_VERSION="${VERSION}"

if [[ "${FORCE}" -eq 1 ]]; then
  export LFS_PACKAGES_REDOWNLOAD=1
  rm -f "${DEST}/$(lfs_packages_tarball_name "${VERSION}")"
fi

DATA_DIR="${ROOT}/data"
LIST="${DATA_DIR}/wget-list-systemd"
MD5="${DATA_DIR}/md5sums"
TARBALL_NAME="$(lfs_packages_tarball_name "${VERSION}")"
TARBALL="${DEST}/${TARBALL_NAME}"

mkdir -p "${DEST}"

if [[ "${LFS_USE_WGET_LIST:-0}" == "1" ]]; then
  echo "==> Downloading via wget-list-systemd"
  [[ -f "${LIST}" ]] || { echo "Missing ${LIST}" >&2; exit 1; }
  wget --input-file="${LIST}" --continue --directory-prefix="${DEST}"
else
  echo "==> Downloading lfs-packages-${VERSION}.tar"
  lfs_packages_download "${DEST}" "${VERSION}"
  echo "==> Extracting into ${DEST}"
  lfs_packages_extract "${TARBALL}" "${DEST}"
  if [[ -f "${LIST}" ]]; then
    echo "==> Verifying wget-list completeness"
    lfs_packages_verify_wget_list "${DEST}" "${LIST}"
  fi
fi

if [[ -f "${MD5}" ]]; then
  echo "==> Verifying md5sums"
  cp "${MD5}" "${DEST}/"
  (cd "${DEST}" && md5sum -c md5sums)
fi

echo ""
echo "Packages ready in: ${DEST}"
