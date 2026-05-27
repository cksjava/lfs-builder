"""Interactive configuration wizard and persistence."""

from __future__ import annotations

import getpass
import json
import os
import platform
import subprocess
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class LFSConfig:
    """User-provided build configuration."""

    lfs_device: str = "/dev/sda1"
    lfs_mount: str = "/mnt/lfs"
    boot_device: str = ""
    boot_mount: str = "/boot"
    separate_boot: bool = False
    swap_device: str = ""
    filesystem: str = "ext4"
    hostname: str = "lfs"
    timezone: str = "UTC"
    keymap: str = "us"
    console_font: str = ""
    lang: str = "en_US.UTF-8"
    hwclock_utc: bool = True
    root_password: str = ""
    grub_device: str = "/dev/sda"
    build_user: str = "lfs"
    jobs: int = 0
    run_tests: bool = True
    book_path: str = ""
    work_dir: str = ""
    verbose: bool = True
    kernel_use_host_config: bool = True
    extra: dict[str, Any] = field(default_factory=dict)

    @property
    def lfs(self) -> str:
        return self.lfs_mount

    @property
    def sources(self) -> str:
        return f"{self.lfs_mount}/sources"

    @property
    def nproc(self) -> int:
        if self.jobs > 0:
            return self.jobs
        return os.cpu_count() or 1

    def lfs_tgt(self) -> str:
        arch = platform.machine()
        return f"{arch}-lfs-linux-gnu"

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d.pop("root_password", None)
        d["root_password_set"] = bool(self.root_password)
        return d

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> LFSConfig:
        extra = data.pop("extra", {})
        data.pop("root_password_set", None)
        cfg = cls(**{k: v for k, v in data.items() if k in cls.__dataclass_fields__})
        cfg.extra = extra
        return cfg


def default_config_path(work_dir: Path) -> Path:
    return work_dir / "lfs-config.json"


def _prompt(text: str, default: str = "") -> str:
    if default:
        val = input(f"{text} [{default}]: ").strip()
        return val or default
    return input(f"{text}: ").strip()


def _prompt_bool(text: str, default: bool = True) -> bool:
    d = "Y/n" if default else "y/N"
    val = input(f"{text} [{d}]: ").strip().lower()
    if not val:
        return default
    return val in ("y", "yes", "1", "true")


def _detect_timezone() -> str:
    tz = os.environ.get("TZ", "")
    if tz:
        return tz
    try:
        link = Path("/etc/localtime").resolve()
        parts = str(link).split("/zoneinfo/")
        if len(parts) > 1:
            return parts[-1]
    except OSError:
        pass
    return "UTC"


def _detect_keymap() -> str:
    try:
        out = subprocess.check_output(
            ["localectl", "list-keymaps"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        # Prefer us if listed
        maps = [l.strip() for l in out.splitlines() if l.strip()]
        for pref in ("us", "uk", maps[0] if maps else "us"):
            if pref in maps:
                return pref
    except (OSError, subprocess.CalledProcessError):
        pass
    return "us"


def run_wizard(
    book_path: Path,
    work_dir: Path,
    *,
    config_file: Path | None = None,
) -> LFSConfig:
    """Collect build parameters interactively."""
    print("\n=== LFS 13.0-systemd Build Configuration ===\n")
    print("Press Enter to accept defaults shown in brackets.\n")

    cfg = LFSConfig()
    cfg.book_path = str(book_path.resolve())
    cfg.work_dir = str(work_dir.resolve())
    cfg.timezone = _prompt("Timezone (e.g. America/New_York)", _detect_timezone())
    cfg.keymap = _prompt("Console keymap", _detect_keymap())
    font_default = cfg.extra.get("console_font", "")
    cfg.console_font = _prompt("Console font (empty for default)", font_default)
    cfg.lang = _prompt("System locale LANG", os.environ.get("LANG", "en_US.UTF-8"))
    cfg.hwclock_utc = _prompt_bool("Hardware clock set to UTC?", True)
    cfg.hostname = _prompt("Target hostname", "lfs")

    print("\n--- Storage ---")
    cfg.lfs_device = _prompt("LFS root partition (e.g. /dev/sda1)", cfg.lfs_device)
    cfg.lfs_mount = _prompt("LFS mount point", "/mnt/lfs")
    cfg.filesystem = _prompt("Root filesystem type", "ext4")
    cfg.separate_boot = _prompt_bool("Separate /boot partition?", False)
    if cfg.separate_boot:
        cfg.boot_device = _prompt("Boot partition device")
        cfg.boot_mount = _prompt("Boot mount inside LFS", "/boot")
    cfg.swap_device = _prompt("Swap partition (empty to skip)", "")
    cfg.grub_device = _prompt("Disk for GRUB install (e.g. /dev/sda)", cfg.grub_device)

    print("\n--- Build options ---")
    cfg.build_user = _prompt("Unprivileged build user", "lfs")
    cfg.jobs = int(_prompt("Parallel make jobs (0=auto)", "0") or "0")
    cfg.run_tests = _prompt_bool("Run package test suites when offered?", True)
    cfg.kernel_use_host_config = _prompt_bool(
        "Seed kernel .config from running host?", True
    )
    cfg.verbose = _prompt_bool("Verbose mode (show all compiler output)?", cfg.verbose)

    pw1 = getpass.getpass("Root password for finished system (empty=skip): ")
    if pw1:
        pw2 = getpass.getpass("Confirm root password: ")
        if pw1 == pw2:
            cfg.root_password = pw1
        else:
            print("Passwords did not match; root password will be set later.")

    path = config_file or default_config_path(work_dir)
    path.parent.mkdir(parents=True, exist_ok=True)
    save_config(cfg, path)
    print(f"\nConfiguration saved to {path}\n")
    return cfg


def save_config(cfg: LFSConfig, path: Path) -> None:
    data = cfg.to_dict()
    data["_root_password"] = cfg.root_password
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    os.chmod(path, 0o600)


def load_config(path: Path) -> LFSConfig:
    data = json.loads(path.read_text(encoding="utf-8"))
    pw = data.pop("_root_password", "")
    cfg = LFSConfig.from_dict(data)
    cfg.root_password = pw
    return cfg
