"""Main LFS build orchestration — runs pre-generated shell scripts."""

from __future__ import annotations

import json
import os
import pwd
import shutil
import subprocess
from pathlib import Path

from .book_version import book_version
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
        *,
        force_format: bool = False,
    ):
        self.book_path = book_path
        self.work_dir = work_dir
        self.cfg = cfg
        self.force_format = force_format
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

    def reset_state(self) -> None:
        """Clear saved build progress (fresh build from step 1)."""
        self._state = {"step_index": 0, "completed": []}
        if self.state_file.exists():
            self.state_file.unlink()

    def _env_base(self) -> dict[str, str]:
        nproc = str(self.cfg.nproc)
        env = {
            "LFS": self.cfg.lfs_mount,
            "LFS_TGT": self.cfg.lfs_tgt(),
            "LFS_DEVICE": self.cfg.lfs_device,
            "LFS_MOUNT": self.cfg.lfs_mount,
            "LFS_SOURCES": self.cfg.sources,
            "LFS_BOOK": str(self.book_path),
            "LFS_BOOK_VERSION": book_version(self.book_path),
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
            "LFS_RUN_TESTS": "1" if self.cfg.run_tests else "0",
            "LFS_FORCE_FORMAT": "1" if self.force_format else "0",
        }
        if not self.cfg.prepare_host:
            env["LFS_SKIP_HOST_PREPARE"] = "1"
        if self.cfg.root_password:
            env["LFS_ROOT_PASSWORD"] = self.cfg.root_password
        return env

    def _lfs_user_env(self, base: dict[str, str], *, builder_scripts: str) -> dict[str, str]:
        """Environment from the book's ~/.bashrc, applied per automated lfs step."""
        lfs = base["LFS"]
        path_parts = [f"{lfs}/tools/bin", "/usr/bin"]
        if not os.path.islink("/bin"):
            path_parts.append("/bin")
        return {
            **os.environ,
            **base,
            "HOME": f"/home/{self.cfg.build_user}",
            "LFS_BUILDER_SCRIPTS": builder_scripts,
            "LC_ALL": "POSIX",
            "PATH": ":".join(path_parts),
            "CONFIG_SITE": f"{lfs}/usr/share/config.site",
        }

    def _script_path(self, entry: dict) -> Path:
        rel = entry["script"]
        return self.scripts_dir / rel

    def _lfs_stage_dir(self) -> Path:
        return Path(self.cfg.sources) / ".lfs-builder-run"

    def _chroot_stage_dir(self) -> Path:
        return self._lfs_stage_dir() / "chroot-runner"

    def _chroot_gcc_env(self, compiler_path: str | None = None) -> list[str]:
        """Minimal env for gcc inside chroot (matches chapter 7)."""
        env = [
            "env",
            "-i",
            "HOME=/root",
            "PATH=/usr/bin:/usr/sbin",
            "LC_ALL=C",
            "LANG=C",
        ]
        if compiler_path:
            env.append(f"COMPILER_PATH={compiler_path}")
        return env

    def _lfs_root(self) -> Path:
        return Path(self.cfg.lfs_mount)

    def _log_gcc_diagnostics(self) -> None:
        """Log gcc layout under $LFS to simplify toolchain failures."""
        lfs = self._lfs_root()
        self._log("[chroot-runner] gcc diagnostics:")
        for pattern in ("usr/bin/*gcc*", "usr/bin/cc"):
            matches = sorted(lfs.glob(pattern))
            if matches:
                for path in matches:
                    self._log(f"  {path.relative_to(lfs)}")
            else:
                self._log(f"  (no {pattern})")
        cc1_files = self._find_cc1_files()
        if cc1_files:
            for path in cc1_files[:5]:
                self._log(f"  cc1: {path.relative_to(lfs)}")
        else:
            self._log("  cc1: not found (gcc-pass2 may be incomplete)")

    def _find_cc1_files(self) -> list[Path]:
        lfs = self._lfs_root()
        sources = lfs / "sources"
        found: list[Path] = []
        for path in lfs.rglob("cc1"):
            if not path.is_file():
                continue
            if sources in path.parents:
                continue
            found.append(path)

        def rank(p: Path) -> tuple[int, str]:
            text = str(p)
            if "/usr/libexec/gcc/" in text:
                return (0, text)
            if "/usr/lib/gcc/" in text:
                return (1, text)
            if "/tools/libexec/gcc/" in text:
                return (2, text)
            if "/tools/lib/gcc/" in text:
                return (3, text)
            return (4, text)

        found.sort(key=rank)
        return found

    def _discover_gcc_toolchain(self) -> dict[str, object] | None:
        """Locate cc1 and the compiler directory inside $LFS."""
        cc1_files = self._find_cc1_files()
        if not cc1_files:
            self._log("[chroot-runner] ERROR: no cc1 found under $LFS")
            self._log_gcc_diagnostics()
            return None

        cc1 = cc1_files[0]
        lfs = self._lfs_root()
        rel = cc1.relative_to(lfs)
        compiler_path = "/" + rel.parent.as_posix()
        spec_path = self._spec_path_for_cc1(rel)
        tools_only = rel.parts[0] == "tools"

        if tools_only:
            self._log(
                "[chroot-runner] warning: cc1 is only under /tools; "
                "chapter 6 gcc-pass2 may not have installed into /usr"
            )

        return {
            "cc1": cc1,
            "compiler_path": compiler_path,
            "spec_path": spec_path,
            "tools_only": tools_only,
        }

    @staticmethod
    def _spec_path_for_cc1(cc1_rel: Path) -> Path | None:
        """Map .../libexec/gcc/T/V/cc1 -> .../lib/gcc/T/V/specs."""
        parts = cc1_rel.parts
        if len(parts) < 5:
            return None
        if parts[1] == "libexec" and parts[2] == "gcc":
            return Path(parts[0], "lib", "gcc", parts[3], parts[4], "specs")
        if parts[1] == "lib" and parts[2] == "gcc":
            return Path(*parts[:-1]) / "specs"
        return None

    def _ensure_gcc_driver_symlink(self) -> None:
        """Ensure /usr/bin/gcc exists when only the triplet-prefixed driver is installed."""
        lfs = self._lfs_root()
        gcc_bin = lfs / "usr/bin/gcc"
        if gcc_bin.exists():
            return
        drivers = sorted(lfs.glob("usr/bin/*-gcc"))
        if not drivers:
            return
        driver = drivers[0]
        gcc_bin.symlink_to(driver.name)
        self._log(
            f"[chroot-runner] created {gcc_bin.relative_to(lfs)} -> {driver.name}"
        )

    def _fix_gcc_specs(self) -> None:
        """Rewrite or create gcc specs so paths work inside chroot."""
        prefix = self.cfg.lfs_mount
        lfs = self._lfs_root()
        toolchain = self._discover_gcc_toolchain()
        if toolchain is None:
            return

        self._ensure_gcc_driver_symlink()
        compiler_path = str(toolchain["compiler_path"])
        spec_path = toolchain.get("spec_path")
        chroot_cmd = ["chroot", lfs, *self._chroot_gcc_env(compiler_path)]

        if spec_path is None:
            self._log("[chroot-runner] warning: could not derive specs path from cc1")
            self._fix_gcc_specs_by_scan(prefix)
            return

        spec_host = lfs / spec_path
        dumpspecs = subprocess.run(
            [*chroot_cmd, "gcc", "-dumpspecs"],
            capture_output=True,
            text=True,
            check=False,
        )
        if dumpspecs.returncode != 0:
            self._log(
                "[chroot-runner] warning: gcc -dumpspecs failed: "
                f"{dumpspecs.stderr.strip()}"
            )
            self._fix_gcc_specs_by_scan(prefix)
            return

        updated = dumpspecs.stdout.replace(prefix, "")
        spec_host.parent.mkdir(parents=True, exist_ok=True)
        spec_host.write_text(updated, encoding="utf-8")
        self._log(
            f"[chroot-runner] wrote gcc specs at {spec_host.relative_to(lfs)} "
            f"(COMPILER_PATH={compiler_path})"
        )

    def _fix_gcc_specs_by_scan(self, prefix: str) -> None:
        """Fallback: strip the mount prefix from every gcc specs file found."""
        lfs = self._lfs_root()
        specs_files = [
            p
            for p in lfs.rglob("specs")
            if p.is_file() and "/gcc/" in p.as_posix() and "sources" not in p.parts
        ]
        if not specs_files:
            self._log("[chroot-runner] warning: no gcc specs file found to patch")
            return
        for spec in specs_files:
            text = spec.read_text(encoding="utf-8", errors="replace")
            if prefix not in text:
                continue
            spec.write_text(text.replace(prefix, ""), encoding="utf-8")
            self._log(
                f"[chroot-runner] stripped {prefix} from "
                f"{spec.relative_to(lfs)}"
            )

    def _stage_script_for_lfs_user(self, script: Path) -> tuple[Path, Path]:
        """Copy script and lib under $LFS/sources so user lfs can read them."""
        stage_dir = self._lfs_stage_dir()
        lib_dir = stage_dir / "lib"
        lib_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(self.scripts_dir / "lib" / "common.sh", lib_dir / "common.sh")

        staged = stage_dir / f"{script.parent.name}-{script.name}"
        text = script.read_text(encoding="utf-8")
        text = text.replace(
            'source "$(dirname "$0")/../lib/common.sh"',
            'source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"',
        )
        text = text.replace(
            'source "$(dirname "$0")/../../lib/common.sh"',
            'source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"',
        )
        staged.write_text(text, encoding="utf-8")
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

    def _run_chroot_batch(self, start_index: int) -> tuple[list[str], int, str | None]:
        """Run a contiguous chroot=true range inside one chroot session."""
        end = start_index
        while end < len(self._steps) and self._steps[end].get("chroot"):
            end += 1

        block = self._steps[start_index:end]
        todo = [e for e in block if e["id"] not in self._state.get("completed", [])]
        if not todo:
            return [], end, None

        self._fix_gcc_specs()
        toolchain = self._discover_gcc_toolchain()

        stage = self._chroot_stage_dir()
        scripts_dir = stage / "scripts"
        lib_dir = stage / "lib"
        scripts_dir.mkdir(parents=True, exist_ok=True)
        lib_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(self.scripts_dir / "lib" / "common.sh", lib_dir / "common.sh")
        (lib_dir / "common.sh").chmod(0o644)

        list_path = stage / "scripts.list"
        completed_path = stage / "completed.txt"
        failed_path = stage / "failed_step.txt"
        run_script = stage / "run-chroot-sequence.sh"
        try:
            completed_path.unlink()
        except FileNotFoundError:
            pass
        try:
            failed_path.unlink()
        except FileNotFoundError:
            pass

        lines: list[str] = []
        for entry in todo:
            src = self._script_path(entry)
            dst = scripts_dir / src.name
            shutil.copy2(src, dst)
            dst.chmod(0o755)
            lines.append(f"{entry['id']}|/sources/.lfs-builder-run/chroot-runner/scripts/{dst.name}")
        list_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

        path_export = "export PATH=/usr/bin:/usr/sbin"
        if toolchain and toolchain.get("tools_only"):
            path_export = "export PATH=/tools/bin:/usr/bin:/usr/sbin"
        compiler_export = ""
        if toolchain:
            compiler_export = (
                f'export COMPILER_PATH="{toolchain["compiler_path"]}"'
            )

        runner_lines = [
            "#!/bin/bash",
            "set -euo pipefail",
            'source "${LFS_BUILDER_SCRIPTS:?}/lib/common.sh"',
            'LFS_STEP_ID="chroot-runner"',
            "log_begin",
            "trap 'log_fail $?; exit 1' ERR",
            'LIST="${LFS_BUILDER_SCRIPTS:?}/scripts.list"',
            'DONE="${LFS_BUILDER_SCRIPTS:?}/completed.txt"',
            'FAILED="${LFS_BUILDER_SCRIPTS:?}/failed_step.txt"',
            ': > "${DONE}"',
            'rm -f "${FAILED}"',
            "",
            'export HOME=/root',
            'export TERM="${TERM:-linux}"',
            'export PS1="(lfs chroot) \\u:\\w\\$ "',
            path_export,
        ]
        if compiler_export:
            runner_lines.append(compiler_export)
        runner_lines.extend(
            [
                'export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"',
                'export TESTSUITEFLAGS="${TESTSUITEFLAGS:--j$(nproc)}"',
                'export CONFIG_SITE="${CONFIG_SITE:-/usr/share/config.site}"',
                'export LC_ALL=C',
                'export LANG=C',
                "",
                "mkdir -p /mnt",
                "if [ ! -e /mnt/lfs ]; then",
                "  ln -sf / /mnt/lfs",
                "fi",
                "",
                "_resolve_cc1() {",
                "  local cc1",
                '  cc1=$(gcc -print-prog-name=cc1 2>/dev/null || true)',
                '  if [ -n "$cc1" ] && [[ "$cc1" == /* ]] && [ -x "$cc1" ]; then',
                '    printf "%s\\n" "$cc1"',
                "    return 0",
                "  fi",
                "  find /usr/libexec/gcc /usr/lib/gcc /tools/libexec/gcc /tools/lib/gcc \\",
                "    -name cc1 -type f 2>/dev/null | head -1",
                "}",
                "",
                "_verify_chroot_toolchain() {",
                "  local cc1",
                "  cc1=$(_resolve_cc1 || true)",
                '  if [ -z "$cc1" ] || [ ! -x "$cc1" ]; then',
                '    die "gcc cannot run cc1. Check chapter 6 gcc-pass2; see [chroot-runner] gcc diagnostics in the log."',
                "  fi",
            ]
        )
        runner_lines.extend(
            [
                '  echo "int main(void){return 0;}" > /tmp/.lfs-cc-test.c',
                "  gcc /tmp/.lfs-cc-test.c -o /tmp/.lfs-cc-test || die \"gcc test compile failed inside chroot\"",
                '  /tmp/.lfs-cc-test || die "gcc test binary failed inside chroot"',
                "  rm -f /tmp/.lfs-cc-test /tmp/.lfs-cc-test.c",
                "}",
                "_verify_chroot_toolchain",
                "",
                'while IFS="|" read -r step_id script_path; do',
                '  [[ -z "${step_id}" ]] && continue',
                '  log "running ${step_id}"',
                '  if ! bash -e "${script_path}"; then',
                '    echo "${step_id}" > "${FAILED}"',
                "    exit 1",
                "  fi",
                '  echo "${step_id}" >> "${DONE}"',
                'done < "${LIST}"',
                "trap - ERR",
                "log_done",
                "",
            ]
        )
        run_script.write_text("\n".join(runner_lines), encoding="utf-8")
        run_script.chmod(0o755)

        env = self._env_base()
        chroot_env = {
            **os.environ,
            **env,
            "LFS_BUILDER_SCRIPTS": "/sources/.lfs-builder-run/chroot-runner",
            "LFS_SOURCES": "/sources",
            "LC_ALL": "C",
            "LANG": "C",
        }
        nproc = str(self.cfg.nproc)
        term = chroot_env.get("TERM", "linux")
        chroot_path = "/tools/bin:/usr/bin:/usr/sbin" if (
            toolchain and toolchain.get("tools_only")
        ) else "/usr/bin:/usr/sbin"
        cmd = [
            "chroot",
            self.cfg.lfs_mount,
            "/usr/bin/env",
            "-i",
            "HOME=/root",
            f"TERM={term}",
            "PS1=(lfs chroot) \\u:\\w\\$ ",
            f"PATH={chroot_path}",
            f"MAKEFLAGS=-j{nproc}",
            f"TESTSUITEFLAGS=-j{nproc}",
            "CONFIG_SITE=/usr/share/config.site",
            "LC_ALL=C",
            "LANG=C",
            "LFS_BUILDER_SCRIPTS=/sources/.lfs-builder-run/chroot-runner",
            "LFS_SOURCES=/sources",
        ]
        if toolchain:
            cmd.append(f"COMPILER_PATH={toolchain['compiler_path']}")
        cmd.extend(
            [
                "/bin/bash",
                "-e",
                "/sources/.lfs-builder-run/chroot-runner/run-chroot-sequence.sh",
            ]
        )
        self._log(
            f"[chroot-runner] executing {len(todo)} step(s): "
            f"{todo[0]['id']} -> {todo[-1]['id']}"
        )
        rc = subprocess.call(cmd, env=chroot_env)

        completed_ids: list[str] = []
        if completed_path.exists():
            completed_ids = [
                ln.strip()
                for ln in completed_path.read_text(encoding="utf-8").splitlines()
                if ln.strip()
            ]

        failed_id: str | None = None
        if failed_path.exists():
            text = failed_path.read_text(encoding="utf-8").strip()
            failed_id = text or None
        elif rc != 0:
            # Defensive fallback if runner failed before writing failed_step.txt
            for entry in todo:
                if entry["id"] not in completed_ids:
                    failed_id = entry["id"]
                    break
        return completed_ids, end, failed_id

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
            lfs_env = self._lfs_user_env(env, builder_scripts=str(builder_scripts))
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

        i = start
        while i < len(self._steps):
            entry = self._steps[i]
            if entry["id"] in self._state.get("completed", []):
                i += 1
                continue
            if entry.get("chroot"):
                completed_ids, end, failed_id = self._run_chroot_batch(i)
                for sid in completed_ids:
                    if sid not in self._state.setdefault("completed", []):
                        self._state["completed"].append(sid)
                if failed_id:
                    failed_idx = i
                    for j in range(i, end):
                        if self._steps[j]["id"] == failed_id:
                            failed_idx = j
                            break
                    self._state["step_index"] = failed_idx
                    self._save_state()
                    self._log(f"\n[FAILED] Step {failed_id}: chroot batch failed")
                    raise subprocess.CalledProcessError(1, failed_id)
                self._state["step_index"] = end
                self._save_state()
                i = end
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
            i += 1

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
