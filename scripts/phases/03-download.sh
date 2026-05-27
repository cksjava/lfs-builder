#!/bin/bash
# Download sources and patches per chapter 3.
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"
LFS_STEP_ID="03-download"
log_begin
trap 'log_fail $?' ERR

require_root
require_var LFS_MOUNT
require_var LFS_BOOK

export LFS="${LFS_MOUNT}"
LIST="${LFS_BOOK}/wget-list-systemd"
MD5="${LFS_BOOK}/md5sums"
DEST="${LFS}/sources"

[[ -f "${LIST}" ]] || die "wget list not found: ${LIST}"

log_step 1 3 "download packages to ${DEST}"
mkdir -pv "${DEST}"
cd "${DEST}"

if command -v wget &>/dev/null; then
  set +e
  wget \
    --input-file="${LIST}" \
    --continue \
    --directory-prefix="${DEST}" \
    --tries=5 \
    --timeout=30 \
    --waitretry=5 \
    --retry-connrefused
  rc=$?
  set -e

  if [[ "$rc" -ne 0 ]]; then
    log "wget returned non-zero exit ($rc). Checking for missing files..."
    missing=()
    while IFS= read -r url; do
      [[ -z "$url" ]] && continue
      file="${url##*/}"
      if [[ ! -f "${DEST}/${file}" ]]; then
        missing+=("$file")
      fi
    done < "${LIST}"

    if [[ "${#missing[@]}" -gt 0 ]]; then
      log "Missing ${#missing[@]} files after wget:"
      for f in "${missing[@]}"; do
        echo "  - $f"
      done
      die "Download incomplete (wget exit ${rc}). Re-run this step to resume."
    fi

    log "All files present despite wget exit ${rc}; continuing."
  fi
else
  die "wget is required for downloads"
fi

log_step 2 3 "verify checksums"
if [[ -f "${MD5}" ]]; then
  cp "${MD5}" "${DEST}/"
  cd "${DEST}"
  md5sum -c md5sums || die "Checksum verification failed"
else
  log "no md5sums file; skipping verification"
fi

log_step 3 3 "downloads complete"
log "All sources in ${DEST}"

trap - ERR
log_done
