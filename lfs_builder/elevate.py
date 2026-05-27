"""Re-exec as root via sudo when invoked as normal user."""

from __future__ import annotations

import os
import shutil
import shlex
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


def _resolve_priv_cmd(name: str) -> str | None:
    """Locate runuser/su even when caller PATH omits /usr/sbin."""
    found = shutil.which(name)
    if found:
        return found
    for candidate in (f"/usr/sbin/{name}", f"/sbin/{name}", f"/bin/{name}"):
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return candidate
    return None


def drop_to_user(username: str, command: list[str], env: dict[str, str] | None = None) -> int:
    runuser = _resolve_priv_cmd("runuser")
    if runuser:
        cmd = [runuser, "-u", username, "--", *command]
    else:
        su = _resolve_priv_cmd("su")
        if not su:
            print("Neither runuser nor su found.", file=sys.stderr)
            return 127
        # Non-login su: login shells would source ~/.bash_profile (exec bash).
        cmd = [su, username, "-c", shlex.join(command)]
    return subprocess.call(cmd, env=env or os.environ.copy())
