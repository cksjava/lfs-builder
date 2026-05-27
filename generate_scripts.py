#!/usr/bin/env python3
"""Pre-generate all LFS build shell scripts from the book."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(_ROOT))

from lfs_builder.script_generator import generate_all
from lfs_builder.package_sources import write_package_sources_json


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate LFS build scripts from the book")
    parser.add_argument(
        "--book",
        type=Path,
        default=_ROOT.parent / "13.0",
        help="Path to extracted LFS book",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=_ROOT / "scripts" / "generated",
        help="Output directory for generated scripts",
    )
    args = parser.parse_args()

    book = args.book.resolve()
    if not book.is_dir():
        print(f"Error: book not found at {book}", file=sys.stderr)
        return 1

    out = args.output.resolve()
    pkg_map_path = write_package_sources_json(book)
    print(f"Package sources: {pkg_map_path}")
    print(f"Generating scripts from {book}")
    print(f"Output: {out}")
    entries = generate_all(book, out)
    pkgs = sum(1 for e in entries if e.get("kind") == "PACKAGE")
    print(f"Done: {len(entries)} steps ({pkgs} packages)")
    print(f"Manifest: {out / 'manifest.json'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
