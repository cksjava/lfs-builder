"""Parse LFS book HTML for installation commands and SBU metadata."""

from __future__ import annotations

import html
import re
from pathlib import Path
from typing import NamedTuple


class PackageMeta(NamedTuple):
    name: str
    sbu: float | None
    sbu_range: tuple[float, float] | None
    disk_mb: float | None


def _book_root(book_path: Path) -> Path:
    return book_path if book_path.is_dir() else book_path.parent


def chapter_toc_packages(book_path: Path, chapter: str) -> list[str]:
    """Return package HTML filenames in build order from a chapter TOC."""
    toc = _book_root(book_path) / chapter / f"{chapter}.html"
    if not toc.exists():
        return []
    text = toc.read_text(encoding="utf-8", errors="replace")
    links: list[str] = []
    in_toc = False
    for line in text.splitlines():
        if 'class="toc"' in line:
            in_toc = True
        if in_toc and '<a href="' in line:
            m = re.search(r'href="([^"]+\.html)"', line)
            if m:
                href = m.group(1)
                if href.startswith("../") or href in (
                    "introduction.html",
                    "pkgmgt.html",
                    "aboutdebug.html",
                ):
                    continue
                links.append(href)
        if in_toc and "</div>" in line and links:
            break
    return links


def _installation_html(page_html: str) -> str:
    m = re.search(
        r'<div class="installation"[^>]*>(.*?)</div>\s*<div class="content"',
        page_html,
        re.DOTALL,
    )
    if m:
        return m.group(1)
    m = re.search(
        r'<div class="installation"[^>]*>(.*)',
        page_html,
        re.DOTALL,
    )
    return m.group(1) if m else page_html


def _strip_pre_block(block: str) -> str:
    text = re.sub(r"<(/?)(em|strong|span)[^>]*>", "", block)
    text = re.sub(r"<code[^>]*>", "", text)
    text = re.sub(r"</code>", "", text)
    text = re.sub(r"<kbd[^>]*>", "", text)
    text = re.sub(r"</kbd>", "", text)
    text = re.sub(r"<[^>]+>", "", text)
    return html.unescape(text).strip()


def extract_commands(html_path: Path, *, setup_page: bool = False) -> list[str]:
    """Extract shell command blocks from a book HTML page."""
    page = html_path.read_text(encoding="utf-8", errors="replace")
    section = page if setup_page else _installation_html(page)
    blocks = re.findall(
        r'<pre class="userinput">(.*?)</pre>',
        section,
        re.DOTALL,
    )
    commands: list[str] = []
    for block in blocks:
        cmd = _strip_pre_block(block)
        if not cmd:
            continue
        # Skip pure documentation examples
        if cmd.startswith("echo $LFS"):
            continue
        commands.append(cmd)
    return commands


def parse_sbu(html_path: Path) -> PackageMeta:
    page = html_path.read_text(encoding="utf-8", errors="replace")
    name_m = re.search(r"<h1[^>]*>[\d.]+\s+([^<]+)</h1>", page)
    name = html.unescape(name_m.group(1).strip()) if name_m else html_path.stem

    sbu = None
    sbu_range = None
    sbu_m = re.search(
        r"Approximate build time:</strong>\s*<span[^>]*>([^<]+)</span>",
        page,
    )
    if sbu_m:
        raw = sbu_m.group(1).strip()
        range_m = re.match(
            r"([\d.]+)\s*-\s*([\d.]+)\s*SBU(?:\s*\([^)]+\))?",
            raw,
        )
        single_m = re.match(r"([\d.]+)\s*SBU", raw)
        if range_m:
            sbu_range = (float(range_m.group(1)), float(range_m.group(2)))
            sbu = (sbu_range[0] + sbu_range[1]) / 2
        elif single_m:
            sbu = float(single_m.group(1))

    disk_mb = None
    disk_m = re.search(
        r"Required disk space:</strong>\s*<span[^>]*>([^<]+)</span>",
        page,
    )
    if disk_m:
        dm = re.search(r"([\d.]+)\s*([KMGT]?B)", disk_m.group(1), re.I)
        if dm:
            val = float(dm.group(1))
            unit = dm.group(2).upper()
            mult = {"KB": 1 / 1024, "MB": 1, "GB": 1024, "TB": 1024 * 1024}
            disk_mb = val * mult.get(unit, 1)

    return PackageMeta(name=name, sbu=sbu, sbu_range=sbu_range, disk_mb=disk_mb)


def _page_title(html_path: Path) -> str | None:
    page = html_path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"<h1[^>]*>(.*?)</h1>", page, re.DOTALL)
    if not m:
        return None
    text = re.sub(r"<[^>]+>", " ", m.group(1))
    text = re.sub(r"\s+", " ", html.unescape(text)).strip()
    # Drop leading section number: "5.2. Binutils-2.46.0 - Pass 1"
    text = re.sub(r"^[\d.]+\s+", "", text)
    return text or None


def package_dir_from_page(html_path: Path) -> str | None:
    """Source directory name (e.g. binutils-2.46.0) from tar commands or h1 title."""
    for cmd in extract_commands(html_path):
        m = re.search(r"tar\s+[^\n]*\s+([^\s/]+\.tar\.[a-z]{2,3})", cmd)
        if m:
            inner = re.match(r"([^-]+-[\d.]+)", m.group(1))
            if inner:
                return inner.group(1)
    title = _page_title(html_path)
    if not title:
        return None
    title = title.replace("::", "-")
    # "Binutils-2.46.0 - Pass 1" / "Libstdc++ from GCC-15.2.0"
    pkg_m = re.search(
        r"([A-Za-z][A-Za-z0-9+.:_-]*-\d[\w.]*)(?:\s+-\s+|\s+from\s+|$)",
        title,
        re.I,
    )
    if pkg_m:
        return pkg_m.group(1).lower()
    pkg_m = re.search(r"from\s+([A-Za-z][A-Za-z0-9+.:_-]*-\d[\w.]*)", title, re.I)
    if pkg_m:
        return pkg_m.group(1).lower()
    return None


def tarball_name_from_page(html_path: Path) -> str | None:
    """Alias for package_dir_from_page."""
    return package_dir_from_page(html_path)
