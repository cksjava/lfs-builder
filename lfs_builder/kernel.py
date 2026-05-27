"""Kernel configuration helpers — seed from host running kernel."""

from __future__ import annotations

import gzip
import shutil
import subprocess
from pathlib import Path


def find_host_config() -> Path | None:
    version = subprocess.check_output(["uname", "-r"], text=True).strip()
    candidates = [
        Path(f"/boot/config-{version}"),
        Path("/proc/config.gz"),
        Path("/boot/config"),
    ]
    for p in candidates:
        if p.exists():
            return p
    return None


def copy_host_config_to_kernel_tree(sources_dir: Path, linux_version: str) -> Path:
    """Copy host config into linux source tree as .config."""
    src_dir = sources_dir / f"linux-{linux_version}"
    if not src_dir.exists():
        # find linux-* directory
        matches = list(sources_dir.glob("linux-[0-9]*"))
        if not matches:
            raise FileNotFoundError("Linux source directory not found in sources")
        src_dir = matches[0]

    host_cfg = find_host_config()
    dest = src_dir / ".config"
    if host_cfg is None:
        return dest

    if host_cfg.suffix == ".gz" or str(host_cfg).endswith("config.gz"):
        with gzip.open(host_cfg, "rb") as f:
            dest.write_bytes(f.read())
    else:
        shutil.copy2(host_cfg, dest)
    return dest


def apply_lfs_mandatory_config(src_dir: Path) -> None:
    """Run olddefconfig after optional fragment; book mandates specific symbols."""
    subprocess.run(
        ["make", "olddefconfig"],
        cwd=src_dir,
        check=True,
        env={**dict(__import__("os").environ), "TERM": "linux"},
    )
    # Enable systemd-related essentials via scripts/config if available
    cfg_script = src_dir / "scripts" / "config"
    if not cfg_script.exists():
        return
    options = [
        "--disable", "WERROR",
        "--enable", "CGROUPS",
        "--enable", "MEMCG",
        "--enable", "INOTIFY_USER",
        "--enable", "SIGNALFD",
        "--enable", "TIMERFD",
        "--enable", "EPOLL",
        "--enable", "TMPFS",
        "--enable", "TMPFS_POSIX_ACL",
        "--enable", "DEVTMPFS",
        "--enable", "DEVTMPFS_MOUNT",
        "--disable", "UEVENT_HELPER",
        "--enable", "NET",
        "--enable", "INET",
        "--enable", "IPV6",
        "--enable", "PSI",
    ]
    subprocess.run(
        [str(cfg_script), *options],
        cwd=src_dir,
        check=False,
    )
    subprocess.run(["make", "olddefconfig"], cwd=src_dir, check=True)
