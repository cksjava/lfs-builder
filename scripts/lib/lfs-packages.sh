# shellcheck shell=bash
# Download and extract lfs-packages-VERSION.tar (all LFS sources + patches).

lfs_packages_tarball_name() {
  local version="${1:?version required}"
  echo "lfs-packages-${version}.tar"
}

lfs_packages_version() {
  if [[ -n "${LFS_BOOK_VERSION:-}" ]]; then
    echo "${LFS_BOOK_VERSION}"
    return 0
  fi
  if [[ -n "${LFS_BOOK:-}" && -d "${LFS_BOOK}" ]]; then
    local base
    base="$(basename "${LFS_BOOK}")"
    if [[ "${base}" =~ ^([0-9]+\.[0-9]+) ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
    if [[ -f "${LFS_BOOK}/index.html" ]]; then
      local ver
      ver=$(grep -oE 'id="lfs-[0-9]+\.[0-9]+' "${LFS_BOOK}/index.html" | head -1 | grep -oE '[0-9]+\.[0-9]+')
      if [[ -n "${ver}" ]]; then
        echo "${ver}"
        return 0
      fi
    fi
  fi
  echo "13.0"
}

lfs_packages_download() {
  local dest="${1:?dest required}"
  local version="${2:?version required}"
  local tarball_name
  tarball_name="$(lfs_packages_tarball_name "$version")"
  local tarball="${dest}/${tarball_name}"
  local mirrors_file="${LFS_PACKAGES_MIRRORS:-}"

  mkdir -p "${dest}"

  if [[ -f "${tarball}" && "${LFS_PACKAGES_REDOWNLOAD:-0}" != "1" ]]; then
    echo "Using cached ${tarball}"
    return 0
  fi

  if [[ -n "${LFS_PACKAGES_URL:-}" ]]; then
    echo "Downloading ${LFS_PACKAGES_URL}"
    _lfs_packages_fetch "${LFS_PACKAGES_URL}" "${tarball}" || return 1
    return 0
  fi

  if [[ -z "${mirrors_file}" ]]; then
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  mirrors_file="${script_dir}/../../data/lfs-packages-mirrors.txt"
  fi

  local mirror url
  while IFS= read -r mirror || [[ -n "${mirror}" ]]; do
    [[ -z "${mirror}" || "${mirror}" =~ ^[[:space:]]*# ]] && continue
    mirror="${mirror%/}/"
    url="${mirror}${tarball_name}"
    echo "Trying ${url}"
    if _lfs_packages_fetch "${url}" "${tarball}"; then
      return 0
    fi
  done < "${mirrors_file}"

  echo "All mirrors failed for ${tarball_name}" >&2
  return 1
}

_lfs_packages_fetch() {
  local url="$1"
  local out="$2"
  if command -v wget >/dev/null; then
    wget --continue --timestamping -O "${out}" "${url}"
    return $?
  fi
  if command -v curl >/dev/null; then
    curl -fL --retry 3 -C - -o "${out}" "${url}"
    return $?
  fi
  echo "Need wget or curl to download packages" >&2
  return 1
}

lfs_packages_extract() {
  local tarball="${1:?tarball required}"
  local dest="${2:?dest required}"
  local tmp

  mkdir -p "${dest}"
  tmp="$(mktemp -d)"

  echo "Extracting ${tarball} into ${dest}"
  tar -xf "${tarball}" -C "${tmp}"

  local -a entries=()
  shopt -s nullglob
  entries=("${tmp}"/*)
  shopt -u nullglob

  if [[ ${#entries[@]} -eq 1 && -d "${entries[0]}" ]]; then
    shopt -s dotglob
    mv "${entries[0]}"/* "${dest}/"
    shopt -u dotglob
  else
    shopt -s dotglob
    mv "${tmp}"/* "${dest}/"
    shopt -u dotglob
  fi
  rm -rf "${tmp}"
}

lfs_packages_verify_wget_list() {
  local dest="${1:?dest}"
  local list="${2:?wget list}"
  local missing=0
  local url file

  while IFS= read -r url || [[ -n "${url}" ]]; do
    [[ -z "${url}" || "${url}" =~ ^[[:space:]]*# ]] && continue
    file="${url##*/}"
    if [[ ! -f "${dest}/${file}" ]]; then
      echo "Missing: ${file}"
      missing=$((missing + 1))
    fi
  done < "${list}"

  if [[ "${missing}" -gt 0 ]]; then
    echo "${missing} file(s) from wget-list not present in ${dest}" >&2
    return 1
  fi
  return 0
}
