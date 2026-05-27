"""Derive LFS book version (e.g. 13.0) from an extracted HTML book tree."""

from __future__ import annotations

import re
from pathlib import Path


def book_version(book_path: Path) -> str:
    """Return major.minor version used for lfs-packages-VERSION.tar."""
    book_path = book_path.resolve()
    m = re.fullmatch(r"(\d+\.\d+)(?:-systemd)?", book_path.name)
    if m:
        return m.group(1)

    index = book_path / "index.html"
    if index.is_file():
        text = index.read_text(encoding="utf-8", errors="replace")
        m = re.search(r'id="lfs-(\d+\.\d+)', text)
        if m:
            return m.group(1)
        m = re.search(r"Version\s+(\d+\.\d+)", text, re.IGNORECASE)
        if m:
            return m.group(1)

    raise ValueError(
        f"Cannot determine LFS book version from {book_path} "
        "(expected directory name like 13.0 or index.html with lfs-13.0-systemd)"
    )
