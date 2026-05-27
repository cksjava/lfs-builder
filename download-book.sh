#!/bin/bash
# Download and extract the LFS 13.0-systemd HTML book.
#
# Default layout (matches build_lfs.py and generate_scripts.py):
#   lfs-builder/          this repo
#   13.0/                 extracted book (sibling of lfs-builder)
#
# Usage (after clone):
#   ./download-book.sh
#   ./prep.sh             # or: sudo ./prep.sh
#   ./build_lfs.py

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BOOK_VERSION="13.0"
BOOK_DIR_NAME="13.0"
TARBALL_NAME="LFS-BOOK-${BOOK_VERSION}.tar.xz"
BOOK_URL="https://www.linuxfromscratch.org/lfs/downloads/${BOOK_VERSION}-systemd/${TARBALL_NAME}"
DEFAULT_DEST="$(cd "${ROOT}/.." && pwd)"

DEST="${DEFAULT_DEST}"
FORCE=0

usage() {
  cat <<EOF
Download and extract the LFS ${BOOK_VERSION}-systemd HTML book.

  $0                     Install to ${DEFAULT_DEST}/${BOOK_DIR_NAME}/ (default)
  $0 --dest DIR          Extract under DIR (creates DIR/${BOOK_DIR_NAME}/)
  $0 --force             Re-download and replace an existing book tree
  $0 --help              Show this help

Official tarball: ${BOOK_URL}

After extraction, build_lfs.py uses: ${DEFAULT_DEST}/${BOOK_DIR_NAME}/
Pass a different path with: ./build_lfs.py --book PATH
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
    --force)
      FORCE=1
      shift
      ;;
    *)
      echo "$0: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

BOOK_DIR="${DEST}/${BOOK_DIR_NAME}"
TARBALL="${DEST}/${TARBALL_NAME}"
MARKER="${BOOK_DIR}/index.html"

if [[ -f "$MARKER" && "$FORCE" -eq 0 ]]; then
  echo "OK: LFS book already present at ${BOOK_DIR}"
  echo "    (use --force to re-download and replace)"
  exit 0
fi

if ! command -v wget >/dev/null && ! command -v curl >/dev/null; then
  echo "$0: need wget or curl to download the book" >&2
  exit 1
fi

mkdir -p "$DEST"

if [[ "$FORCE" -eq 1 ]]; then
  echo "==> Removing existing book at ${BOOK_DIR}"
  rm -rf "$BOOK_DIR"
  rm -f "$TARBALL"
fi

if [[ ! -f "$TARBALL" ]]; then
  echo "==> Downloading ${TARBALL_NAME}"
  echo "    ${BOOK_URL}"
  if command -v wget >/dev/null; then
    wget --continue --timestamping -O "$TARBALL" "$BOOK_URL"
  else
    curl -fL --retry 3 -o "$TARBALL" "$BOOK_URL"
  fi
else
  echo "==> Using cached tarball ${TARBALL}"
fi

echo "==> Extracting to ${DEST}"
tar -xf "$TARBALL" -C "$DEST"

if [[ ! -f "$MARKER" ]]; then
  echo "$0: extraction failed — missing ${MARKER}" >&2
  exit 1
fi

echo ""
echo "Book ready at: ${BOOK_DIR}"
echo "Next steps:"
echo "  cd ${ROOT}"
echo "  sudo ./prep.sh"
echo "  ./build_lfs.py"
