#!/bin/bash
# Download all LFS sources and patches in one tarball (lfs-packages-VERSION.tar).
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
# shellcheck source=../lib/lfs-packages.sh
source "$(dirname "$0")/../lib/lfs-packages.sh"
LFS_STEP_ID="03-download"
log_begin
trap 'log_fail $?' ERR

require_root
require_var LFS_MOUNT

export LFS="${LFS_MOUNT}"
DATA_DIR="$(cd "$(dirname "$0")/../../data" && pwd)"
LIST="${LFS_WGET_LIST:-${DATA_DIR}/wget-list-systemd}"
MD5="${LFS_MD5SUMS:-${DATA_DIR}/md5sums}"
DEST="${LFS}/sources"
VERSION="$(lfs_packages_version)"
TARBALL_NAME="$(lfs_packages_tarball_name "${VERSION}")"
TARBALL="${DEST}/${TARBALL_NAME}"

mkdir -pv "${DEST}"

if [[ "${LFS_USE_WGET_LIST:-0}" == "1" ]]; then
  log_step 1 3 "download packages via wget-list (legacy)"
  [[ -f "${LIST}" ]] || die "wget list not found: ${LIST}"
  cd "${DEST}"
  wget \
    --input-file="${LIST}" \
    --continue \
    --directory-prefix="${DEST}" \
    --tries=5 \
    --timeout=30 \
    --waitretry=5 \
    --retry-connrefused
else
  log_step 1 3 "download lfs-packages-${VERSION}.tar to ${DEST}"
  if ! lfs_packages_download "${DEST}" "${VERSION}"; then
    log "Tarball download failed; falling back to wget-list"
    if [[ -f "${LIST}" ]]; then
      cd "${DEST}"
      wget \
        --input-file="${LIST}" \
        --continue \
        --directory-prefix="${DEST}" \
        --tries=5 \
        --timeout=30 \
        --waitretry=5 \
        --retry-connrefused || die "wget-list download failed"
    else
      die "Could not download lfs-packages-${VERSION}.tar and no wget-list at ${LIST}"
    fi
  else
    log_step 2 3 "extract ${TARBALL_NAME}"
    lfs_packages_extract "${TARBALL}" "${DEST}"
    if [[ -f "${LIST}" ]]; then
      log "verify all wget-list files are present"
      lfs_packages_verify_wget_list "${DEST}" "${LIST}" || die "Package tarball is incomplete"
    fi
  fi
fi

log_step 3 3 "verify checksums"
if [[ -f "${MD5}" ]]; then
  cp "${MD5}" "${DEST}/"
  cd "${DEST}"
  md5sum -c md5sums || die "Checksum verification failed"
else
  log "no md5sums file; skipping verification"
fi

log "All sources in ${DEST}"
trap - ERR
log_done
