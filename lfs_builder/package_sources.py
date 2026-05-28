"""Authoritative package source directories from wget-list + explicit overrides."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

from .manifest import BuildStep, StepKind, build_manifest

_PACKAGE_SOURCES_PATH = Path(__file__).resolve().parent.parent / "data" / "package-sources.json"
_WGET_LIST_PATH = Path(__file__).resolve().parent.parent / "data" / "wget-list-systemd"

# Steps with no extracted source tree (book commands only).
NO_SOURCE_STEPS = frozenset({"stripping", "cleanup", "ch8-cleanup"})

# Keep the extracted tree after these steps (a later step reuses the same directory).
SKIP_SOURCE_CLEANUP_AFTER = frozenset({"linux-headers"})

# Do not remove an existing tree before extract (kernel reuses linux-headers tree).
SKIP_SOURCE_REMOVE_BEFORE = frozenset({"kernel"})

# Explicit overrides where tarball name, extract directory, or step id do not align.
# Prefer wget-list auto-match; add entries here only when needed.
PACKAGE_OVERRIDES: dict[str, dict[str, str]] = {
    # Multi-pass / sub-builds share one tree
    "binutils-pass1": {"tarball_glob": "binutils-2.46.0", "build_dir": "binutils-2.46.0"},
    "binutils-pass2": {"tarball_glob": "binutils-2.46.0", "build_dir": "binutils-2.46.0"},
    "binutils": {"tarball_glob": "binutils-2.46.0", "build_dir": "binutils-2.46.0"},
    "gcc-pass1": {"tarball_glob": "gcc-15.2.0", "build_dir": "gcc-15.2.0"},
    "gcc-pass2": {"tarball_glob": "gcc-15.2.0", "build_dir": "gcc-15.2.0"},
    "gcc-libstdc++": {"tarball_glob": "gcc-15.2.0", "build_dir": "gcc-15.2.0"},
    "gcc": {"tarball_glob": "gcc-15.2.0", "build_dir": "gcc-15.2.0"},
    # Book page has no tar extract; kernel API headers only
    "linux-headers": {"tarball_glob": "linux-6.18.10", "build_dir": "linux-6.18.10"},
    "kernel": {"tarball_glob": "linux-6.18.10", "build_dir": "linux-6.18.10"},
    # Tarball / directory naming mismatches
    "Python": {"tarball_glob": "Python-3.14.3", "build_dir": "Python-3.14.3"},
    "libelf": {"tarball_glob": "elfutils-0.194", "build_dir": "elfutils-0.194"},
    "xml-parser": {"tarball_glob": "XML-Parser-2.47", "build_dir": "XML-Parser-2.47"},
    "flit-core": {"tarball_glob": "flit_core-3.12.0", "build_dir": "flit_core-3.12.0"},
    "dbus": {"tarball_glob": "dbus-1.16.2", "build_dir": "dbus-1.16.2"},
    "sqlite": {
        "tarball_glob": "sqlite-autoconf-3510200",
        "build_dir": "sqlite-autoconf-3510200",
    },
    "tcl": {"tarball_glob": "tcl8.6.17-src", "build_dir": "tcl8.6.17"},
    "expect": {"tarball_glob": "expect5.45.4", "build_dir": "expect5.45.4"},
    "ninja": {"tarball_glob": "ninja-1.13.2", "build_dir": "ninja-1.13.2"},
    "util-linux": {"tarball_glob": "util-linux-2.41.3", "build_dir": "util-linux-2.41.3"},
}


@dataclass(frozen=True)
class PackageSource:
    tarball_glob: str
    build_dir: str

    @classmethod
    def from_dict(cls, data: dict[str, str]) -> PackageSource:
        return cls(tarball_glob=data["tarball_glob"], build_dir=data["build_dir"])


def _tarball_basename(url: str) -> str:
    name = url.rsplit("/", 1)[-1]
    return re.sub(r"\.tar\.(gz|xz|bz2)$", "", name, flags=re.I)


def _load_wget_tarballs(wget_path: Path | None = None) -> list[str]:
    path = wget_path or _WGET_LIST_PATH
    tarballs: list[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ".tar." not in line:
            continue
        tarballs.append(_tarball_basename(line))
    return tarballs


def _match_tarball(step_id: str, html_stem: str, tarballs: list[str]) -> str | None:
    """Match a package step to a wget-list tarball basename."""
    if step_id in PACKAGE_OVERRIDES:
        return PACKAGE_OVERRIDES[step_id]["tarball_glob"]

    stem = html_stem.replace(".html", "")
    candidates: list[str] = []

    for base in tarballs:
        lower = base.lower()
        if lower.startswith(stem.lower() + "-"):
            candidates.append(base)
            continue
        sid = step_id.lower().replace("_", "-")
        if lower.startswith(sid + "-"):
            candidates.append(base)

    if len(candidates) == 1:
        return candidates[0]
    if len(candidates) > 1:
        # Prefer exact step-id prefix over html stem when both match
        sid = step_id.lower().replace("_", "-")
        for base in candidates:
            if base.lower().startswith(sid + "-"):
                return base
        return sorted(candidates)[0]
    return None


def build_package_sources(
    book_path: Path,
    *,
    wget_path: Path | None = None,
) -> dict[str, PackageSource | None]:
    """Build step-id -> source mapping for all package steps in the manifest."""
    tarballs = _load_wget_tarballs(wget_path)
    mapping: dict[str, PackageSource | None] = {}

    for step in build_manifest(book_path):
        if step.kind != StepKind.PACKAGE and step.id not in PACKAGE_OVERRIDES:
            continue
        if step.kind != StepKind.PACKAGE and step.id in PACKAGE_OVERRIDES:
            entry = PACKAGE_OVERRIDES[step.id]
            mapping[step.id] = PackageSource(
                tarball_glob=entry["tarball_glob"],
                build_dir=entry["build_dir"],
            )
            continue
        if step.id in NO_SOURCE_STEPS:
            mapping[step.id] = None
            continue

        if step.id in PACKAGE_OVERRIDES:
            entry = PACKAGE_OVERRIDES[step.id]
            mapping[step.id] = PackageSource(
                tarball_glob=entry["tarball_glob"],
                build_dir=entry["build_dir"],
            )
            continue

        html_stem = Path(step.html).name
        tarball = _match_tarball(step.id, html_stem, tarballs)
        if not tarball:
            raise ValueError(
                f"No tarball match for package step {step.id!r} ({step.html}); "
                f"add PACKAGE_OVERRIDES entry in package_sources.py"
            )
        mapping[step.id] = PackageSource(tarball_glob=tarball, build_dir=tarball)

    return mapping


def write_package_sources_json(
    book_path: Path,
    output_path: Path | None = None,
    *,
    wget_path: Path | None = None,
) -> Path:
    mapping = build_package_sources(book_path, wget_path=wget_path)
    out = output_path or _PACKAGE_SOURCES_PATH
    payload = {
        "book": str(book_path),
        "wget_list": str(wget_path or _WGET_LIST_PATH),
        "no_source": sorted(NO_SOURCE_STEPS),
        "packages": {
            step_id: None if src is None else {
                "tarball_glob": src.tarball_glob,
                "build_dir": src.build_dir,
            }
            for step_id, src in sorted(mapping.items())
        },
    }
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return out


def load_package_sources(path: Path | None = None) -> dict[str, PackageSource | None]:
    src_path = path or _PACKAGE_SOURCES_PATH
    if not src_path.is_file():
        raise FileNotFoundError(
            f"Package source map not found at {src_path}. Run: ./generate_scripts.py"
        )
    data = json.loads(src_path.read_text(encoding="utf-8"))
    out: dict[str, PackageSource | None] = {}
    for step_id, entry in data.get("packages", {}).items():
        if entry is None:
            out[step_id] = None
        else:
            out[step_id] = PackageSource.from_dict(entry)
    return out


def source_for_step(step: BuildStep, cache: dict[str, PackageSource | None]) -> PackageSource | None:
    if step.kind != StepKind.PACKAGE:
        return None
    if step.id not in cache:
        raise KeyError(
            f"Package source missing for step {step.id!r}; regenerate package-sources.json"
        )
    return cache[step.id]
