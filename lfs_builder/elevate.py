"""Re-exec as root via sudo when invoked as normal user."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys


def ensure_root() -> None:
    if os.geteuid() == 0:
        return
    sudo = shutil.which("sudo")
    if not sudo:
        print("This build must run as root. Re-run as root or install sudo.", file=sys.stderr)
        sys.exit(1)
    print("Re-executing with root privileges (sudo)...")
    os.execvp(
        sudo,
        [sudo, "-E", sys.executable, *sys.argv],
    )


def drop_to_user(username: str, command: list[str], env: dict[str, str] | None = None) -> int:
    runuser = shutil.which("runuser") or shutil.which("su")
    if runuser and os.path.basename(runuser) == "runuser":
        cmd = ["runuser", "-u", username, "--", *command]
    else:
        cmd = ["su", "-", username, "-c", " ".join(command)]
    return subprocess.call(cmd, env=env or os.environ.copy())
