"""Generate static shell scripts from the LFS book HTML."""

from __future__ import annotations

import json
import re
import stat
from pathlib import Path

from .book_parser import extract_commands, package_dir_from_page, parse_sbu
from .manifest import BuildStep, StepKind, build_manifest


def _filter_commands(step: BuildStep, commands: list[str]) -> list[str]:
    out: list[str] = []
    for cmd in commands:
        if step.id == "chroot-enter" and cmd.strip().startswith("chroot "):
            continue
        if step.id == "mount" and "mkdir -pv $LFS" in cmd:
            continue
        if cmd.strip().startswith("passwd "):
            continue
        if step.id == "kernel" and "menuconfig" in cmd:
            continue
        out.append(cmd)
    return out


def _normalize_commands(commands: list[str]) -> list[str]:
    """Use runtime env vars for user-configurable book placeholders."""
    text = "\n\n".join(commands)
    text = re.sub(r"/dev/<[^>]+>", '"$LFS_DEVICE"', text)
    text = re.sub(r"LFS=&lt;xxx&gt;", 'LFS="$LFS"', text)
    text = re.sub(r"<xxx>", '"${LFS_DEVICE#/dev/}"', text)
    text = re.sub(r"KEYMAP=[a-z0-9_-]+", 'KEYMAP="$LFS_KEYMAP"', text)
    text = re.sub(r"LANG=[a-zA-Z0-9_.@-]+", 'LANG="$LFS_LANG"', text)
    # Split back on blank lines between original blocks
    return [b.strip() for b in text.split("\n\n") if b.strip()]


def _script_header(step: BuildStep, meta_name: str | None) -> list[str]:
    lib = 'source "$(dirname "$0")/../../lib/common.sh"'
    lines = [
        "#!/bin/bash",
        f"# LFS 13.0-systemd — {step.phase} / {step.id}",
        f"# Generated from book; do not edit — re-run generate_scripts.py",
    ]
    if meta_name:
        lines.append(f"# {meta_name}")
    if step.user == "lfs":
        lines.append("# RUN_AS: lfs")
    if step.chroot:
        lines.append("# RUN_IN_CHROOT: yes")
    lines.extend(["set -euo pipefail", lib, ""])
    return lines


def _package_preamble(tarball: str | None, meta_name: str) -> list[str]:
    if not tarball:
        return []
    return [
        f"# Package: {meta_name}",
        'cd "${LFS_SOURCES:?}"',
        f'TARBALL=$(ls -1 {tarball}*.tar.* 2>/dev/null | head -1)',
        f'if [ -n "$TARBALL" ] && [ ! -d "{tarball}" ]; then',
        '  echo "Extracting $TARBALL..."',
        '  tar -xf "$TARBALL"',
        "fi",
        f'cd "{tarball}"',
        "",
    ]


def _wrap_chroot(body_lines: list[str]) -> list[str]:
    body = "\n".join(body_lines)
    return [
        'require_var LFS',
        'chroot "${LFS}" /usr/bin/env -i \\',
        '    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \\u:\\w\\$ " \\',
        '    PATH=/usr/bin:/usr/sbin \\',
        '    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \\',
        '    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \\',
        "    /bin/bash -euo pipefail <<'CHROOT_EOF'",
        body,
        "CHROOT_EOF",
    ]


def generate_step_script(
    book_path: Path,
    step: BuildStep,
    out_path: Path,
) -> dict:
    """Write one step script; return metadata for manifest."""
    meta: dict = {
        "phase": step.phase,
        "id": step.id,
        "kind": step.kind.name,
        "script": str(out_path.relative_to(out_path.parents[2])),
        "chroot": step.chroot,
        "user": step.user,
        "sbu": None,
        "book_html": step.html,
    }

    if step.kind == StepKind.SCRIPT:
        # Hand-written phase scripts stay in scripts/phases/
        meta["script"] = f"phases/{step.script}"
        return meta

    html_path = book_path / step.html
    book_meta = parse_sbu(html_path)
    meta["sbu"] = book_meta.sbu
    meta["name"] = book_meta.name

    commands = extract_commands(
        html_path,
        setup_page=step.setup_page or step.kind == StepKind.SETUP,
    )
    commands = _filter_commands(step, commands)
    commands = _normalize_commands(commands)

    lines = _script_header(step, book_meta.name)

    if step.kind == StepKind.PACKAGE:
        pkg_dir = package_dir_from_page(html_path)
        lines.extend(_package_preamble(pkg_dir, book_meta.name))
    elif step.id in ("host-check", "filesystem", "aboutlfs", "mount"):
        lines.append('require_var LFS')
        lines.append("")
    elif step.chroot:
        pass
    else:
        lines.append('require_var LFS')
        lines.append("")

    body = list(commands)
    if not body and step.kind == StepKind.PACKAGE:
        body = ['echo "WARNING: no commands extracted"']

    if step.chroot:
        lines.extend(_wrap_chroot(body))
    else:
        lines.extend(body)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    content = "\n".join(lines) + "\n"
    out_path.write_text(content, encoding="utf-8")
    out_path.chmod(out_path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return meta


def generate_all(
    book_path: Path,
    output_dir: Path,
) -> list[dict]:
    """Generate all scripts and manifest.json under output_dir."""
    manifest_steps = build_manifest(book_path)
    entries: list[dict] = []

    for index, step in enumerate(manifest_steps):
        seq = index + 1
        if step.kind == StepKind.SCRIPT:
            entries.append(
                {
                    "index": index,
                    "seq": seq,
                    "phase": step.phase,
                    "id": step.id,
                    "kind": step.kind.name,
                    "script": f"phases/{step.script}",
                    "chroot": False,
                    "user": step.user,
                    "sbu": None,
                    "book_html": None,
                }
            )
            continue

        script_name = f"{seq:03d}-{step.id}.sh"
        out_path = output_dir / step.phase / script_name
        meta = generate_step_script(book_path, step, out_path)
        meta["index"] = index
        meta["seq"] = seq
        entries.append(meta)

    # Kernel host-config helper (called by orchestrator before kernel script)
    kernel_helper = output_dir / "09-bootable" / "kernel-host-config.sh"
    kernel_helper.write_text(
        """#!/bin/bash
# Seed kernel .config from host — invoked by orchestrator before 0NN-kernel.sh
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
require_var LFS_SOURCES
LINUX_DIR=$(ls -d "${LFS_SOURCES}"/linux-* 2>/dev/null | head -1)
if [ -z "$LINUX_DIR" ]; then
  echo "Linux source tree not found in ${LFS_SOURCES}" >&2
  exit 1
fi
cd "$LINUX_DIR"
HOST_CFG=""
for c in "/boot/config-$(uname -r)" /proc/config.gz /boot/config; do
  [ -e "$c" ] && HOST_CFG=$c && break
done
if [ -n "$HOST_CFG" ]; then
  echo "Using host config: $HOST_CFG"
  if [[ "$HOST_CFG" == *.gz ]]; then
    zcat "$HOST_CFG" > .config
  else
    cp "$HOST_CFG" .config
  fi
  make olddefconfig
  if [ -x scripts/config ]; then
    scripts/config --disable WERROR --enable CGROUPS --enable MEMCG \\
      --enable INOTIFY_USER --enable SIGNALFD --enable TIMERFD --enable EPOLL \\
      --enable TMPFS --enable TMPFS_POSIX_ACL --enable DEVTMPFS \\
      --enable DEVTMPFS_MOUNT --disable UEVENT_HELPER --enable NET \\
      --enable INET --enable IPV6 --enable PSI || true
    make olddefconfig
  fi
else
  echo "No host kernel config found; run make defconfig manually" >&2
  exit 1
fi
""",
        encoding="utf-8",
    )
    kernel_helper.chmod(0o755)

    manifest_path = output_dir / "manifest.json"
    manifest_path.write_text(
        json.dumps({"book": str(book_path), "steps": entries}, indent=2) + "\n",
        encoding="utf-8",
    )
    return entries
