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
        if step.id == "mount" and "swapon" in cmd:
            continue
        if step.id == "filesystem":
            continue
        if step.id == "aboutlfs" and "export LFS=" in cmd:
            continue
        if step.id == "environment":
            if cmd.strip() in ("make -j32", "export MAKEFLAGS=-j32"):
                continue
            if "bash.bashrc" in cmd:
                continue  # book: run as root, handled by orchestrator
            if cmd.strip() == "source ~/.bash_profile":
                continue  # exec's interactive bash; orchestrator sets build env
            if "LFS=/mnt/lfs" in cmd:
                cmd = cmd.replace("LFS=/mnt/lfs", 'LFS="$LFS"')
        if step.id == "add-user" and cmd.strip() == "su - lfs":
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


def _shell_quote(s: str) -> str:
    return "'" + s.replace("'", "'\"'\"'") + "'"


def _command_label(cmd: str) -> str:
    """Short human-readable label for a command block."""
    first = cmd.strip().split("\n")[0].strip()
    lower = cmd.lower()
    if "../configure" in lower or "./configure" in lower or first.startswith("../configure"):
        return "configure"
    if re.search(r"\bmake\s+install\b", lower):
        return "make install"
    if "make install" in lower and "DESTDIR" in cmd:
        return "make install (DESTDIR)"
    if re.search(r"\bmake\s+-k\s+check\b", lower) or "make check" in lower:
        return "make check (test suite)"
    if re.search(r"^make\b", first, re.I) or first == "make":
        return "make"
    if first.startswith("tar ") or "\ntar " in cmd:
        return "extract source archive"
    if "patch -" in lower:
        return "apply patch"
    if first.startswith("mkdir "):
        return first[:72]
    if "cat >" in lower or "cat <<" in lower:
        return "write configuration file"
    if first.startswith("ln -"):
        return first[:72]
    if first.startswith("chown ") or first.startswith("chmod "):
        return first[:72]
    if first.startswith("mount "):
        return first[:72]
    if len(first) > 72:
        return first[:69] + "..."
    return first or "run command"


def _idempotentize_line(line: str) -> str:
    """Wrap commands that fail when re-run (resume after partial build)."""
    s = line.strip()
    if not s or s.startswith("#"):
        return line

    m = re.match(r"^groupadd\s+(.+)$", s)
    if m:
        args = m.group(1).strip()
        name = args.split()[-1]
        if not name.startswith("-"):
            return f"getent group {name} &>/dev/null || groupadd {args}"

    m = re.match(r"^useradd\s+(.+)$", s)
    if m and not s.startswith("useradd -D"):
        args = m.group(1).strip()
        name = args.split()[-1]
        if not name.startswith("-"):
            return f"getent passwd {name} &>/dev/null || useradd {args}"

    if s.startswith("mount ") and "mountpoint" not in s:
        parts = s.split()
        target = parts[-1]
        return f"mountpoint -q {target} 2>/dev/null || {s}"

    if s.startswith("ln -sv ") and not s.startswith("ln -svf"):
        return s.replace("ln -sv ", "ln -svf ", 1)
    if re.match(r"^ln\s+-s[^f]", s) and s.startswith("ln -s") and not s.startswith("ln -sf"):
        return re.sub(r"^ln\s+-s", "ln -sf", s, count=1)

    return line


def _idempotentize_command_block(cmd: str) -> str:
    return "\n".join(_idempotentize_line(ln) for ln in cmd.split("\n"))


def _emit_logged_commands(commands: list[str], *, chroot: bool = False) -> list[str]:
    """Prefix each command block with log_step."""
    lines: list[str] = []
    total = len(commands)
    if chroot:
        lines.append('log() { echo "[lfs-chroot $(date +%H:%M:%S)] $*"; }')
        lines.append("")
    for i, cmd in enumerate(commands, 1):
        cmd = _idempotentize_command_block(cmd)
        label = _command_label(cmd)
        lines.append(f"log_step {i} {total} {_shell_quote(label)}")
        lines.extend(cmd.split("\n"))
        lines.append("")
    return lines


def _script_header(step: BuildStep, meta_name: str | None) -> list[str]:
    lib = 'source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"'
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
    lines.extend(
        [
            "set -euo pipefail",
            lib,
            f'LFS_STEP_ID="{step.phase}/{step.id}"',
            "log_begin",
            'trap \'log_fail $?\' ERR',
            "",
        ]
    )
    return lines


def _script_footer() -> list[str]:
    return ["trap - ERR", "log_done", ""]


def _package_preamble(tarball: str | None, meta_name: str) -> list[str]:
    if not tarball:
        return []
    return [
        f"# Package: {meta_name}",
        'log "enter sources directory"',
        'cd "${LFS_SOURCES:?}"',
        'log "extract source tarball (if needed)"',
        f'TARBALL=$(ls -1 {tarball}*.tar.* 2>/dev/null | head -1)',
        f'if [ -n "$TARBALL" ] && [ ! -d "{tarball}" ]; then',
        '  log "Extracting $TARBALL"',
        '  tar -xf "$TARBALL"',
        "fi",
        f'cd "{tarball}"',
        'log "Building in $(pwd)"',
        "",
    ]


def _wrap_chroot(body_lines: list[str]) -> list[str]:
    body = "\n".join(body_lines)
    return [
        'require_var LFS',
        'log "entering chroot at ${LFS}"',
        'chroot "${LFS}" /usr/bin/env -i \\',
        '    HOME=/root TERM="${TERM:-linux}" PS1="(lfs chroot) \\u:\\w\\$ " \\',
        '    PATH=/usr/bin:/usr/sbin \\',
        '    MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}" \\',
        '    TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}" \\',
        "    /bin/bash -euo pipefail <<'CHROOT_EOF'",
        body,
        "CHROOT_EOF",
        'log "left chroot"',
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
    elif step.id in ("host-check", "aboutlfs"):
        lines.append('require_var LFS')
        lines.append("")
    elif step.id == "filesystem":
        lines = _script_header(step, book_meta.name)
        lines.append('log "Skipping: partition formatted by 01-partition.sh"')
        lines.extend(_script_footer())
    elif step.id == "mount":
        lines = _script_header(step, book_meta.name)
        lines.append('require_var LFS')
        lines.append('[ -d "${LFS}" ] || die "LFS not mounted — run partition step first"')
        lines.append('log_step 1 2 "set LFS mount ownership"')
        lines.append('chown root:root "${LFS}" 2>/dev/null || true')
        lines.append('log_step 2 2 "set LFS mount permissions"')
        lines.append('chmod 755 "${LFS}"')
        lines.extend(_script_footer())
    elif step.chroot:
        pass
    else:
        lines.append('require_var LFS')
        lines.append("")

    body = list(commands)
    if step.id in ("filesystem", "mount"):
        body = []
    if not body and step.kind == StepKind.PACKAGE:
        body = ['echo "WARNING: no commands extracted"']

    if body:
        logged = _emit_logged_commands(body, chroot=step.chroot)
        if step.chroot:
            lines.extend(_wrap_chroot(logged))
        else:
            lines.extend(logged)

    if step.id not in ("filesystem", "mount"):
        lines.extend(_script_footer())

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
source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"
LFS_STEP_ID="09-bootable/kernel-host-config"
log_begin
trap 'log_fail $?' ERR

require_var LFS_SOURCES
log_step 1 4 "locate Linux source tree"
LINUX_DIR=$(ls -d "${LFS_SOURCES}"/linux-* 2>/dev/null | head -1)
if [ -z "$LINUX_DIR" ]; then
  die "Linux source tree not found in ${LFS_SOURCES}"
fi
cd "$LINUX_DIR"
log "Using ${LINUX_DIR}"

log_step 2 4 "copy host kernel config"
HOST_CFG=""
for c in "/boot/config-$(uname -r)" /proc/config.gz /boot/config; do
  [ -e "$c" ] && HOST_CFG=$c && break
done
if [ -z "$HOST_CFG" ]; then
  die "No host kernel config found; run make defconfig manually"
fi
log "Host config: $HOST_CFG"
if [[ "$HOST_CFG" == *.gz ]]; then
  zcat "$HOST_CFG" > .config
else
  cp "$HOST_CFG" .config
fi

log_step 3 4 "apply olddefconfig"
make olddefconfig

log_step 4 4 "enable LFS mandatory kernel options"
if [ -x scripts/config ]; then
  scripts/config --disable WERROR --enable CGROUPS --enable MEMCG \\
    --enable INOTIFY_USER --enable SIGNALFD --enable TIMERFD --enable EPOLL \\
    --enable TMPFS --enable TMPFS_POSIX_ACL --enable DEVTMPFS \\
    --enable DEVTMPFS_MOUNT --disable UEVENT_HELPER --enable NET \\
    --enable INET --enable IPV6 --enable PSI || true
  make olddefconfig
fi

trap - ERR
log_done
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
