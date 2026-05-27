"""SBU calibration and time-remaining estimates."""

from __future__ import annotations

import json
import time
from pathlib import Path


class SBUTracker:
    """Track Standard Build Units calibrated from Binutils Pass 1."""

    CALIBRATION_ID = "binutils-pass1"

    def __init__(self, state_path: Path):
        self.state_path = state_path
        self._sbu_seconds: float | None = None
        self._load()

    def _load(self) -> None:
        if self.state_path.exists():
            data = json.loads(self.state_path.read_text(encoding="utf-8"))
            self._sbu_seconds = data.get("sbu_seconds")

    def save(self) -> None:
        self.state_path.parent.mkdir(parents=True, exist_ok=True)
        self.state_path.write_text(
            json.dumps({"sbu_seconds": self._sbu_seconds}, indent=2) + "\n",
            encoding="utf-8",
        )

    @property
    def calibrated(self) -> bool:
        return self._sbu_seconds is not None and self._sbu_seconds > 0

    def calibrate(self, elapsed_seconds: float) -> None:
        self._sbu_seconds = elapsed_seconds
        self.save()

    def estimate_seconds(self, sbu: float | None) -> float | None:
        if sbu is None or not self.calibrated or self._sbu_seconds is None:
            return None
        return sbu * self._sbu_seconds

    def format_eta(self, sbu: float | None) -> str:
        secs = self.estimate_seconds(sbu)
        if secs is None:
            return "ETA: unknown (SBU not calibrated)"
        if secs < 60:
            return f"ETA: ~{secs:.0f}s"
        if secs < 3600:
            return f"ETA: ~{secs / 60:.1f} min"
        return f"ETA: ~{secs / 3600:.1f} h"

    def format_remaining(
        self,
        packages: list[tuple[str, float | None]],
        current_index: int,
    ) -> str:
        if not self.calibrated or self._sbu_seconds is None:
            return "Remaining: unknown"
        total = 0.0
        for i, (_, sbu) in enumerate(packages):
            if i >= current_index and sbu:
                total += sbu * self._sbu_seconds
        if total < 60:
            return f"Remaining: ~{total:.0f}s"
        if total < 3600:
            return f"Remaining: ~{total / 60:.1f} min"
        return f"Remaining: ~{total / 3600:.1f} h"


class BuildTimer:
    def __init__(self):
        self._start: float | None = None

    def start(self) -> None:
        self._start = time.monotonic()

    def elapsed(self) -> float:
        if self._start is None:
            return 0.0
        return time.monotonic() - self._start
