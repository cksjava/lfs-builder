"""LFS chapter 2.2 host system verification and preparation."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


def version_check_script(scripts_dir: Path) -> Path:
    return scripts_dir.parent / "version-check.sh"


def run_version_check(scripts_dir: Path, *, verbose: bool = True) -> int:
    vc = version_check_script(scripts_dir)
    if not vc.is_file():
        raise FileNotFoundError(f"Missing host check script: {vc}")
    vc.chmod(vc.stat().st_mode | 0o111)
    proc = subprocess.run(
        ["bash", str(vc)],
        env={**os.environ, "LC_ALL": "C", "PATH": "/usr/bin:/bin"},
    )
    return proc.returncode


def run_host_prepare(scripts_dir: Path, *, skip: bool = False) -> int:
    if skip:
        print("[lfs] Skipping host prepare (prepare_host=false)")
        return 0
    script = scripts_dir / "phases" / "00-host-prepare.sh"
    env = {**os.environ, "LFS_BUILDER_SCRIPTS": str(scripts_dir)}
    if skip:
        env["LFS_SKIP_HOST_PREPARE"] = "1"
    return subprocess.call(["bash", "-e", str(script)], env=env)


def run_host_check(scripts_dir: Path) -> int:
    script = scripts_dir / "phases" / "00-host-check.sh"
    env = {**os.environ, "LFS_BUILDER_SCRIPTS": str(scripts_dir)}
    return subprocess.call(["bash", "-e", str(script)], env=env)
