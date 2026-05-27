"""Command execution with quiet/verbose modes and logging."""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable


LogFn = Callable[[str], None]


class CommandRunner:
    def __init__(
        self,
        *,
        verbose: bool = False,
        log: LogFn | None = None,
        env: dict[str, str] | None = None,
        cwd: str | Path | None = None,
    ):
        self.verbose = verbose
        self.log = log or print
        self.env = env
        self.cwd = str(cwd) if cwd else None

    def _merged_env(self, extra: dict[str, str] | None) -> dict[str, str]:
        e = os.environ.copy()
        if self.env:
            e.update(self.env)
        if extra:
            e.update(extra)
        return e

    def run_script(
        self,
        script_path: Path,
        *,
        extra_env: dict[str, str] | None = None,
        check: bool = True,
    ) -> int:
        self.log(f"[run] {script_path.name}")
        if self.verbose:
            return self._run_foreground(
                ["bash", "-e", str(script_path)],
                extra_env=extra_env,
                check=check,
            )
        return self._run_logged(
            ["bash", "-e", str(script_path)],
            label=script_path.name,
            extra_env=extra_env,
            check=check,
        )

    def run_shell(
        self,
        commands: str,
        *,
        label: str = "shell",
        extra_env: dict[str, str] | None = None,
        check: bool = True,
        as_user: str | None = None,
    ) -> int:
        self.log(f"[run] {label}")
        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".sh",
            delete=False,
            encoding="utf-8",
        ) as tf:
            tf.write("#!/bin/bash\nset -e\n")
            tf.write(commands)
            if not commands.endswith("\n"):
                tf.write("\n")
            script = tf.name
        os.chmod(script, 0o700)
        try:
            cmd = ["bash", "-e", script]
            if as_user:
                cmd = ["runuser", "-u", as_user, "--", "bash", "-e", script]
            if self.verbose:
                return self._run_foreground(cmd, extra_env=extra_env, check=check)
            return self._run_logged(cmd, label=label, extra_env=extra_env, check=check)
        finally:
            try:
                os.unlink(script)
            except OSError:
                pass

    def _run_foreground(
        self,
        cmd: list[str],
        *,
        extra_env: dict[str, str] | None,
        check: bool,
    ) -> int:
        proc = subprocess.run(
            cmd,
            env=self._merged_env(extra_env),
            cwd=self.cwd,
        )
        if check and proc.returncode != 0:
            raise subprocess.CalledProcessError(proc.returncode, cmd)
        return proc.returncode

    def _run_logged(
        self,
        cmd: list[str],
        *,
        label: str,
        extra_env: dict[str, str] | None,
        check: bool,
    ) -> int:
        work = Path(tempfile.gettempdir()) / "lfs-builder-logs"
        work.mkdir(parents=True, exist_ok=True)
        logfile = work / f"{label.replace('/', '_')}.log"
        with open(logfile, "w", encoding="utf-8") as lf:
            proc = subprocess.run(
                cmd,
                env=self._merged_env(extra_env),
                cwd=self.cwd,
                stdout=lf,
                stderr=subprocess.STDOUT,
            )
        if proc.returncode != 0:
            self.log(f"[error] Command failed (see {logfile})")
            tail = logfile.read_text(encoding="utf-8", errors="replace")[-4000:]
            print(tail, file=sys.stderr)
            if check:
                raise subprocess.CalledProcessError(proc.returncode, cmd)
        else:
            self.log(f"[ok] {label}")
        return proc.returncode
