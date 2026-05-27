"""Build manifest: ordered phases and packages from the LFS book."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from .book_parser import chapter_toc_packages


class StepKind(Enum):
    PACKAGE = "package"
    SETUP = "setup"
    SCRIPT = "script"


@dataclass
class BuildStep:
    phase: str
    id: str
    html: str | None
    kind: StepKind
    script: str | None = None
    chroot: bool = False
    user: str | None = None  # None = root, "lfs" = build user
    setup_page: bool = False


# Chapter 7: non-package setup steps before chroot packages
CH7_SETUP_BEFORE_CHROOT = [
    ("changingowner", "changingowner.html", True, False),
    ("kernfs", "kernfs.html", True, False),
    ("chroot-enter", "chroot.html", True, False),
    ("creatingdirs", "creatingdirs.html", True, True),
    ("createfiles", "createfiles.html", True, True),
]

CH7_PACKAGES = [
    "gettext.html",
    "bison.html",
    "perl.html",
    "Python.html",
    "texinfo.html",
    "util-linux.html",
]

CH7_AFTER = [
    ("cleanup", "cleanup.html", True, True),
]

# Non-package chapters rendered as setup pages
CH2_SETUP = [
    ("host-check", "hostreqs.html"),
    ("filesystem", "creatingfilesystem.html"),
    ("aboutlfs", "aboutlfs.html"),
    ("mount", "mounting.html"),
]

CH4_SETUP = [
    ("min-layout", "creatingminlayout.html"),
    ("add-user", "addinguser.html"),
    ("environment", "settingenvironment.html"),
]

CH9_SETUP = [
    ("network", "network.html"),
    ("udev", "udev.html"),
    ("symlinks", "symlinks.html"),
    ("clock", "clock.html"),
    ("console", "console.html"),
    ("locale", "locale.html"),
    ("inputrc", "inputrc.html"),
    ("etcshells", "etcshells.html"),
    ("systemd-custom", "systemd-custom.html"),
]

CH10_SETUP = [
    ("fstab", "fstab.html"),
    ("kernel", "kernel.html"),
    ("grub", "grub.html"),
]


def build_manifest(book_path: Path) -> list[BuildStep]:
    book = book_path
    steps: list[BuildStep] = []

    def add_phase(phase: str, items: list[BuildStep]) -> None:
        for s in items:
            steps.append(
                BuildStep(
                    phase=phase,
                    id=s.id,
                    html=s.html,
                    kind=s.kind,
                    script=s.script,
                    chroot=s.chroot,
                    user=s.user,
                    setup_page=s.setup_page,
                )
            )

    # Phase 1: host preparation (root)
    p1: list[BuildStep] = [
        BuildStep("01-prepare", "partition", None, StepKind.SCRIPT, "01-partition.sh"),
    ]
    for sid, html in CH2_SETUP:
        p1.append(
            BuildStep(
                "01-prepare", sid, f"chapter02/{html}", StepKind.SETUP, setup_page=True
            )
        )
    p1.append(
        BuildStep("01-prepare", "sources-dir", None, StepKind.SCRIPT, "02-sources-dir.sh")
    )
    add_phase("01-prepare", p1)

    # Phase 2: downloads
    add_phase(
        "02-download",
        [
            BuildStep(
                "02-download",
                "wget",
                None,
                StepKind.SCRIPT,
                "03-download.sh",
            )
        ],
    )

    # Phase 3: final preparations (root + lfs user env)
    p3: list[BuildStep] = []
    for sid, html in CH4_SETUP:
        ch = "chapter04"
        p3.append(
            BuildStep(
                "03-toolchain-prep",
                sid,
                f"{ch}/{html}",
                StepKind.SETUP,
                user="lfs" if sid == "environment" else None,
                setup_page=True,
            )
        )
    p3.append(
        BuildStep(
            "03-toolchain-prep",
            "config-site",
            None,
            StepKind.SCRIPT,
            "04-config-site.sh",
            user="lfs",
        )
    )
    add_phase("03-toolchain-prep", p3)

    # Phase 4: cross toolchain (lfs user)
    for pkg in chapter_toc_packages(book, "chapter05"):
        steps.append(
            BuildStep(
                "04-cross-toolchain",
                pkg.replace(".html", ""),
                f"chapter05/{pkg}",
                StepKind.PACKAGE,
                user="lfs",
            )
        )

    # Phase 5: cross temp tools (lfs)
    for pkg in chapter_toc_packages(book, "chapter06"):
        steps.append(
            BuildStep(
                "05-cross-temp",
                pkg.replace(".html", ""),
                f"chapter06/{pkg}",
                StepKind.PACKAGE,
                user="lfs",
            )
        )

    # Phase 6: enter chroot environment (root, then inside chroot)
    p6: list[BuildStep] = []
    for sid, html, setup, chroot in CH7_SETUP_BEFORE_CHROOT:
        p6.append(
            BuildStep(
                "06-chroot-temp",
                sid,
                f"chapter07/{html}",
                StepKind.SETUP,
                chroot=chroot,
                setup_page=setup,
            )
        )
    for pkg in CH7_PACKAGES:
        p6.append(
            BuildStep(
                "06-chroot-temp",
                pkg.replace(".html", ""),
                f"chapter07/{pkg}",
                StepKind.PACKAGE,
                chroot=True,
            )
        )
    for sid, html, setup, chroot in CH7_AFTER:
        p6.append(
            BuildStep(
                "06-chroot-temp",
                sid,
                f"chapter07/{html}",
                StepKind.SETUP,
                chroot=chroot,
                setup_page=setup,
            )
        )
    add_phase("06-chroot-temp", p6)

    # Phase 7: final system (chroot)
    ch8_pkgs = chapter_toc_packages(book, "chapter08")
    skip = {"pkgmgt.html", "aboutdebug.html"}
    for pkg in ch8_pkgs:
        if pkg in skip:
            continue
        steps.append(
            BuildStep(
                "07-system",
                pkg.replace(".html", ""),
                f"chapter08/{pkg}",
                StepKind.PACKAGE,
                chroot=True,
            )
        )
    steps.append(
        BuildStep(
            "07-system",
            "stripping",
            "chapter08/stripping.html",
            StepKind.SETUP,
            chroot=True,
            setup_page=True,
        )
    )
    steps.append(
        BuildStep(
            "07-system",
            "ch8-cleanup",
            "chapter08/cleanup.html",
            StepKind.SETUP,
            chroot=True,
            setup_page=True,
        )
    )

    # Phase 8: configuration (chroot, templated)
    for sid, html in CH9_SETUP:
        steps.append(
            BuildStep(
                "08-config",
                sid,
                f"chapter09/{html}",
                StepKind.SETUP,
                chroot=True,
                setup_page=True,
            )
        )

    # Phase 9: bootable (chroot)
    for sid, html in CH10_SETUP:
        steps.append(
            BuildStep(
                "09-bootable",
                sid,
                f"chapter10/{html}",
                StepKind.SETUP,
                chroot=True,
                setup_page=True,
            )
        )

    # Phase 10: finish
    steps.append(
        BuildStep(
            "10-finish",
            "reboot-prep",
            None,
            StepKind.SCRIPT,
            "99-finish.sh",
        )
    )

    return steps
