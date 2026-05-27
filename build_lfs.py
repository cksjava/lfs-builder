#!/usr/bin/env python3
"""
Automated Linux From Scratch (LFS) 13.0-systemd builder.

Run as a normal user; the script re-executes via sudo for root operations.
"""

from __future__ import annotations

import argparse
import os
import stat
import sys
from pathlib import Path

# Allow running without install
_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(_ROOT))

from lfs_builder.config import default_config_path, load_config, run_wizard, save_config
from lfs_builder.elevate import ensure_root
from lfs_builder.host_requirements import run_host_check, run_host_prepare
from lfs_builder.orchestrator import LFSOrchestrator


def _default_book() -> Path:
    candidate = _ROOT.parent / "13.0"
    if candidate.is_dir():
        return candidate
    return _ROOT / "book"


def _default_work() -> Path:
    return _ROOT / "work"


def _make_scripts_executable() -> None:
    for sh in (_ROOT / "scripts").rglob("*.sh"):
        mode = sh.stat().st_mode
        sh.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    for vc in (
        _ROOT / "version-check.sh",
        _ROOT / "prep.sh",
        _ROOT / "download-book.sh",
        _ROOT / "download-packages.sh",
        _ROOT / "data" / "version-check.sh",
    ):
        if vc.is_file():
            vc.chmod(vc.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build LFS 13.0-systemd automatically from the book",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Interactive setup, then full build
  %(prog)s --resume           # Continue from last saved step
  %(prog)s --cleanup          # Unmount LFS and virtual filesystems
  %(prog)s --clean            # Alias for --cleanup
  %(prog)s -v                 # Verbose (show compiler output)
  %(prog)s --config work/lfs-config.json --resume
        """,
    )
    parser.add_argument(
        "--book",
        type=Path,
        default=None,
        help="Path to extracted LFS book (default: ../13.0)",
    )
    parser.add_argument(
        "--work-dir",
        type=Path,
        default=_default_work(),
        help="Working directory for config, state, logs",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="Configuration JSON file",
    )
    parser.add_argument(
        "--cleanup",
        "--clean",
        action="store_true",
        dest="cleanup",
        help="Unmount virtual filesystems, LFS partition, and swap",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Resume build from last saved step",
    )
    parser.add_argument(
        "--from-step",
        type=int,
        default=None,
        metavar="N",
        help="Start at step index N (0-based)",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Show all command output (compiler logs, etc.)",
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Suppress compiler output (default)",
    )
    parser.add_argument(
        "--reconfigure",
        action="store_true",
        help="Run configuration wizard even if config exists",
    )
    parser.add_argument(
        "--check-host",
        action="store_true",
        help="Verify host meets LFS chapter 2.2 requirements and exit",
    )
    parser.add_argument(
        "--prepare-host",
        action="store_true",
        help="Install host packages (apt/dnf) and verify; exit without building",
    )
    parser.add_argument(
        "--skip-host-prepare",
        action="store_true",
        help="Do not install host packages during the build (still runs version check)",
    )
    args = parser.parse_args()

    _make_scripts_executable()

    book = (args.book or _default_book()).resolve()
    if not book.is_dir():
        print(f"Error: LFS book not found at {book}", file=sys.stderr)
        print("Run ./download-book.sh or pass --book PATH", file=sys.stderr)
        return 1

    generated_manifest = _ROOT / "scripts" / "generated" / "manifest.json"
    if not generated_manifest.exists() and not args.cleanup:
        print("Error: pre-generated scripts not found.", file=sys.stderr)
        print("Run: ./generate_scripts.py", file=sys.stderr)
        return 1

    work_dir = args.work_dir.resolve()
    work_dir.mkdir(parents=True, exist_ok=True)
    config_path = args.config or default_config_path(work_dir)

    scripts_dir = _ROOT / "scripts"

    if args.check_host or args.prepare_host:
        ensure_root()
        if args.prepare_host:
            rc = run_host_prepare(scripts_dir, skip=False)
            if rc != 0:
                return rc
        if args.check_host:
            return run_host_check(scripts_dir)
        return 0

    if args.cleanup:
        ensure_root()
        if not config_path.exists():
            print("Warning: no config; using environment variables for LFS_MOUNT")
            from lfs_builder.config import LFSConfig

            cfg = LFSConfig(lfs_mount=os.environ.get("LFS", "/mnt/lfs"))
        else:
            cfg = load_config(config_path)
        orch = LFSOrchestrator(book, work_dir, cfg)
        orch.cleanup()
        return 0

    if args.reconfigure or not config_path.exists():
        cfg = run_wizard(book, work_dir, config_file=config_path)
    else:
        cfg = load_config(config_path)

    if args.verbose:
        cfg.verbose = True
    if args.quiet:
        cfg.verbose = False
    if args.skip_host_prepare:
        cfg.prepare_host = False

    save_config(cfg, config_path)

    ensure_root()

    if args.resume:
        start_step = args.from_step
        orch = LFSOrchestrator(book, work_dir, cfg, force_format=False)
        if start_step is None:
            start_step = orch._state.get("step_index", 0)
    else:
        start_step = args.from_step if args.from_step is not None else 0
        force_format = start_step == 0
        orch = LFSOrchestrator(book, work_dir, cfg, force_format=force_format)
        if args.from_step is None:
            orch.reset_state()
        if start_step == 0 and cfg.prepare_host and not args.skip_host_prepare:
            rc = run_host_prepare(scripts_dir, skip=False)
            if rc != 0:
                return rc

    if start_step is None:
            start_step = orch._state.get("step_index", 0)

    rc = run_host_check(scripts_dir)
    if rc != 0 and cfg.prepare_host and not args.skip_host_prepare:
        print("Host check failed; installing missing build dependencies...")
        rc = run_host_prepare(scripts_dir, skip=False)
        if rc != 0:
            return rc
        rc = run_host_check(scripts_dir)
    if rc != 0:
        print(
            "Host does not meet LFS requirements. Run: ./build_lfs.py --prepare-host",
            file=sys.stderr,
        )
        return rc

    from_step = start_step

    try:
        orch.run(from_step=from_step)
    except KeyboardInterrupt:
        print("\nInterrupted. Resume with: build_lfs.py --resume")
        return 130
    except Exception as e:
        print(f"\nBuild failed: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
