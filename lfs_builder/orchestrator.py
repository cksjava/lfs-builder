"""Main LFS build orchestration — runs pre-generated shell scripts."""

from __future__ import annotations

import json
import os
import pwd
import shutil
import subprocess
from pathlib import Path

from .config import LFSConfig, load_config, run_wizard
from .elevate import drop_to_user, ensure_root
from .manifest import StepKind, build_manifest
from .runner import CommandRunner
from .sbu import BuildTimer, SBUTracker


class LFSOrchestrator:
    def __init__(
        self,
        book_path: Path,
        work_dir: Path,
        cfg: LFSConfig,
    ):
        self.book_path = book_path
        self.work_dir = work_dir
        self.cfg = cfg
        self.scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
        self.generated_dir = self.scripts_dir / "generated"
        self.state_file = work_dir / "build-state.json"
        self.sbu = SBUTracker(work_dir / "sbu.json")
        self.runner = CommandRunner(verbose=cfg.verbose, log=self._log)
        self._steps = self._load_generated_manifest()
        self._state = self._load_state()

    def _log(self, msg: str) -> None:
        print(msg, flush=True)

    def _load_generated_manifest(self) -> list[dict]:
        path = self.generated_dir / "manifest.json"
        if not path.exists():
            raise FileNotFoundError(
                f"Generated scripts not found at {self.generated_dir}.\n"
                "Run: ./generate_scripts.py"
            )
        data = json.loads(path.read_text(encoding="utf-8"))
        return data["steps"]

    def _load_state(self) -> dict:
        if self.state_file.exists():
            return json.loads(self.state_file.read_text(encoding="utf-8"))
        return {"step_index": 0, "completed": []}

    def _save_state(self) -> None:
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        self.state_file.write_text(
            json.dumps(self._state, indent=2) + "\n",
            encoding="utf-8",
        )

    def _env_base(self) -> dict[str, str]:
        nproc = str(self.cfg.nproc)
        env = {
            "LFS": self.cfg.lfs_mount,
            "LFS_TGT": self.cfg.lfs_tgt(),
            "LFS_DEVICE": self.cfg.lfs_device,
            "LFS_MOUNT": self.cfg.lfs_mount,
            "LFS_SOURCES": self.cfg.sources,
            "LFS_BOOK": str(self.book_path),
            "LFS_BUILD_USER": self.cfg.build_user,
            "LFS_HOSTNAME": self.cfg.hostname,
            "LFS_TIMEZONE": self.cfg.timezone,
            "LFS_KEYMAP": self.cfg.keymap,
            "LFS_LANG": self.cfg.lang,
            "LFS_GRUB_DEVICE": self.cfg.grub_device,
            "LFS_BOOT_DEVICE": self.cfg.boot_device,
            "LFS_BOOT_MOUNT": self.cfg.boot_mount,
            "LFS_SWAP_DEVICE": self.cfg.swap_device,
            "LFS_FILESYSTEM": self.cfg.filesystem,
            "LFS_SEPARATE_BOOT": "1" if self.cfg.separate_boot else "0",
            "LFS_HWCLOCK_UTC": "1" if self.cfg.hwclock_utc else "0",
            "LFS_CONSOLE_FONT": self.cfg.console_font or "",
            "MAKEFLAGS": f"-j{nproc}",
            "TESTSUITEFLAGS": f"-j{nproc}",
            "PATH": "/usr/sbin:/usr/bin:/sbin:/bin",
            "LFS_BUILDER_SCRIPTS": str(self.scripts_dir),
        }
        if self.cfg.root_password:
            env["LFS_ROOT_PASSWORD"] = self.cfg.root_password
        return env

    def _script_path(self, entry: dict) -> Path:
        rel = entry["script"]
        return self.scripts_dir / rel

    def _lfs_stage_dir(self) -> Path:
        return Path(self.cfg.sources) / ".lfs-builder-run"

    def _stage_script_for_lfs_user(self, script: Path) -> tuple[Path, Path]:
        """Copy script and lib under $LFS/sources so user lfs can read them."""
        stage_dir = self._lfs_stage_dir()
        lib_dir = stage_dir / "lib"
        lib_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(self.scripts_dir / "lib" / "common.sh", lib_dir / "common.sh")

        staged = stage_dir / f"{script.parent.name}-{script.name}"
        shutil.copy2(script, staged)
        staged.chmod(0o755)
        (lib_dir / "common.sh").chmod(0o644)

        try:
            pw = pwd.getpwnam(self.cfg.build_user)
            for path in (stage_dir, lib_dir, lib_dir / "common.sh", staged):
                os.chown(path, pw.pw_uid, pw.pw_gid)
        except KeyError:
            pass  # user not created yet
        return staged, stage_dir

    def _disable_host_bash_bashrc(self) -> None:
        """Book 4.4: move host /etc/bash.bashrc aside (requires root)."""
        bashrc = Path("/etc/bash.bashrc")
        nouse = Path("/etc/bash.bashrc.NOUSE")
        if not bashrc.exists():
            self._log("host /etc/bash.bashrc not present; skipping")
            return
        if nouse.exists():
            self._log("host /etc/bash.bashrc already disabled")
            return
        self._log("moving /etc/bash.bashrc -> /etc/bash.bashrc.NOUSE")
        shutil.move(bashrc, nouse)

    def _run_step(self, index: int, entry: dict) -> None:
        step_id = entry["id"]
        phase = entry["phase"]
        self._log(f"\n{'='*60}")
        self._log(f"Step {index + 1}/{len(self._steps)}: [{phase}] {step_id}")
        self._log(f"{'='*60}")

        env = self._env_base()
        script = self._script_path(entry)

        if not script.exists():
            raise FileNotFoundError(f"Missing script: {script}")

        sbu_val = entry.get("sbu")
        if sbu_val:
            self._log(self.sbu.format_eta(sbu_val))
            remaining = [
                (e["id"], e.get("sbu"))
                for e in self._steps[index:]
                if e.get("kind") == "PACKAGE"
            ]
            self._log(self.sbu.format_remaining(remaining, 0))

        timer = BuildTimer()
        if step_id == "binutils-pass1" and not self.sbu.calibrated:
            timer.start()

        if step_id == "kernel" and self.cfg.kernel_use_host_config:
            helper = self.generated_dir / "09-bootable" / "kernel-host-config.sh"
            if helper.exists():
                self.runner.env = env
                self.runner.run_script(helper, extra_env=env)

        user = entry.get("user")
        if user == "lfs":
            if step_id == "environment":
                self._disable_host_bash_bashrc()
            run_script, builder_scripts = self._stage_script_for_lfs_user(script)
            lfs_env = {
                **os.environ,
                **env,
                "HOME": f"/home/{self.cfg.build_user}",
                "LFS_BUILDER_SCRIPTS": str(builder_scripts),
            }
            rc = drop_to_user(
                self.cfg.build_user,
                ["bash", "-e", str(run_script)],
                env=lfs_env,
            )
            if rc != 0:
                raise subprocess.CalledProcessError(rc, step_id)
        else:
            self.runner.env = env
            self.runner.run_script(script, extra_env=env)

        if step_id == "binutils-pass1" and not self.sbu.calibrated:
            self.sbu.calibrate(timer.elapsed())
            self._log(
                f"SBU calibrated: 1 SBU = {self.sbu._sbu_seconds:.1f}s "
                f"(from binutils-pass1)"
            )

    def run(self, *, from_step: int | None = None) -> None:
        ensure_root()
        start = from_step if from_step is not None else self._state.get("step_index", 0)
        self._log(f"Starting LFS build from step {start + 1}")

        for i in range(start, len(self._steps)):
            entry = self._steps[i]
            if entry["id"] in self._state.get("completed", []):
                continue
            try:
                self._run_step(i, entry)
            except subprocess.CalledProcessError as e:
                self._log(f"\n[FAILED] Step {entry['id']}: {e}")
                self._state["step_index"] = i
                self._save_state()
                raise
            self._state.setdefault("completed", []).append(entry["id"])
            self._state["step_index"] = i + 1
            self._save_state()

        self._log("\n*** LFS build completed successfully ***")
        self._log("Unmount and reboot per chapter 11 when ready.")

    def cleanup(self) -> None:
        ensure_root()
        env = self._env_base()
        script = self.scripts_dir / "phases" / "cleanup.sh"
        self.runner.env = env
        self.runner.run_script(script, extra_env=env)
        self._log("Cleanup finished.")

    @staticmethod
    def prepare_config(
        book_path: Path,
        work_dir: Path,
        config_path: Path | None,
        *,
        non_interactive: bool = False,
    ) -> LFSConfig:
        work_dir.mkdir(parents=True, exist_ok=True)
        cp = config_path or work_dir / "lfs-config.json"
        if cp.exists():
            return load_config(cp)
        if non_interactive:
            raise SystemExit(f"Config not found: {cp}. Run without --resume first.")
        return run_wizard(book_path, work_dir, config_file=cp)
