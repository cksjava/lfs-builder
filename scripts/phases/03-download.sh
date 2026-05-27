#!/bin/bash
# Download sources and patches per chapter 3.
source "$(dirname "$0")/../lib/common.sh"
require_root
require_var LFS_MOUNT
require_var LFS_BOOK

export LFS="${LFS_MOUNT}"
LIST="${LFS_BOOK}/wget-list-systemd"
MD5="${LFS_BOOK}/md5sums"
DEST="${LFS}/sources"

[[ -f "${LIST}" ]] || die "wget list not found: ${LIST}"

log "Downloading packages to ${DEST} (this may take a while)"
mkdir -pv "${DEST}"
cd "${DEST}"

if command -v wget &>/dev/null; then
  wget --input-file="${LIST}" --continue --directory-prefix="${DEST}"
else
  die "wget is required for downloads"
fi

if [[ -f "${MD5}" ]]; then
  log "Verifying checksums"
  cp "${MD5}" "${DEST}/"
  cd "${DEST}"
  md5sum -c md5sums || die "Checksum verification failed"
fi

log "Downloads complete"
