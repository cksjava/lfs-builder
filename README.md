# LFS 13.0-systemd Automated Builder

Unattended build orchestrator for [Linux From Scratch](https://www.linuxfromscratch.org/) **13.0-systemd**, driven by the HTML book in `../13.0/`.

## Features

- Interactive wizard for partition, mount point, timezone, keymap, locale, hostname, GRUB disk, and parallel jobs
- Downloads all sources and patches from bundled `data/wget-list-systemd` with MD5 verification (mirrors fixed when book URLs fail)
- Executes book installation commands in chapter order (cross toolchain → temp tools → chroot → system → config → kernel/GRUB)
- Handles chroot enter/exit, virtual kernel filesystem mounts, and `lfs` user builds
- **Quiet** (default) or **verbose** (`-v`) logging
- **SBU** calibration from Binutils Pass 1 with per-package ETA and remaining-time estimates
- Kernel `.config` seeded from the running host, then LFS mandatory options applied
- **Resume** from last successful step (`--resume`)
- **Cleanup** mode to unmount `$LFS` and virtual filesystems (`--cleanup` or `--clean`)
- Re-executes via `sudo` when started as a normal user

## Requirements

- Host meets LFS 13.0 [host requirements](https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html) — verified automatically before partitioning
- `python3`, `bash`, `wget`, `sudo`, root access
- Extracted book: `../13.0/` (from `LFS-BOOK-13.0.tar.xz`) — used for build instructions only; sources come from `data/`
- Empty partition(s) for LFS (and optional `/boot`, swap)

## Generate build scripts (once per book version)

Scripts are pre-generated from the book HTML and checked into `scripts/generated/`:

```bash
cd lfs-builder
./generate_scripts.py          # Regenerate after book updates
```

This writes **142 shell scripts** under `scripts/generated/<phase>/` plus `manifest.json` and `data/package-sources.json` (authoritative tarball → build-directory map from `data/wget-list-systemd`).

Package source directories come from `data/package-sources.json`, not HTML title parsing. Steps with special tarball/directory names (e.g. `linux-headers`, `Python`, `tcl`, `util-linux`) are listed in `PACKAGE_OVERRIDES` inside `lfs_builder/package_sources.py`.

## Quick start

Prepare and verify the host (chapter 2.2) before the full build:

```bash
cd lfs-builder
./build_lfs.py --prepare-host    # apt install build deps on Debian/Ubuntu
./build_lfs.py --check-host      # version-check only
```

Full build (host prepare + check run automatically before step 1 on a fresh build):

```bash
./build_lfs.py
```

Use `--skip-host-prepare` if packages are already installed. Resume skips host prep/check and does not reformat the LFS partition. A fresh build (without `--resume`) always formats the root partition on step 1.

Answer the prompts once. The script elevates to root and runs through all phases until GRUB is installed.

### Resume after interruption

```bash
./build_lfs.py --resume
```

### Verbose build (all compiler output)

```bash
./build_lfs.py -v --resume
```

### Cleanup mounts

```bash
./build_lfs.py --cleanup   # or: ./build_lfs.py --clean
```

## Layout

```
lfs-builder/
  build_lfs.py           # Main entry point
  generate_scripts.py    # Generate scripts from book (run once)
  lfs_builder/           # Python package
    book_parser.py       # Extract commands & SBU from book HTML
    script_generator.py  # Write scripts/generated/*
    config.py            # Wizard and JSON config
    manifest.py          # Ordered build steps (used by generator)
    orchestrator.py      # Runs pre-generated scripts
    runner.py            # Quiet/verbose execution
    sbu.py               # SBU timing
  data/                  # wget-list-systemd, wget-list, md5sums (fixed mirrors)
  scripts/
    lib/common.sh
    phases/              # Partition, download, cleanup, finish (hand-written)
    generated/           # Pre-generated per-step scripts + manifest.json
      04-cross-toolchain/
      07-system/
      ...
  work/                  # Config, state, logs (created at run time)
```

## Configuration

Saved to `work/lfs-config.json` (mode 600). Includes device paths, preferences, and build options. Re-run the wizard with `--reconfigure`.

## Build phases

| Phase | Book chapters | Description |
|-------|---------------|-------------|
| 01-prepare | 2 | Partition, mount, host prep |
| 02-download | 3 | wget sources + patches |
| 03-toolchain-prep | 4 | `/tools`, `lfs` user, environment |
| 04-cross-toolchain | 5 | Cross binutils, GCC, glibc, … |
| 05-cross-temp | 6 | Temporary system tools |
| 06-chroot-temp | 7 | chroot, dirs, final temp tools |
| 07-system | 8 | Final system software |
| 08-config | 9 | Network, clock, keymap, locale, systemd |
| 09-bootable | 10 | fstab, kernel, GRUB |
| 10-finish | 11 | Reboot instructions |

## Notes

- **Partitioning** is not automated with `fdisk`; create partitions before the run and supply device names at the wizard.
- Build commands live in `scripts/generated/`; re-run `generate_scripts.py` after book changes.
- Interactive steps (e.g. `passwd`, `menuconfig`) are omitted; kernel config uses `kernel-host-config.sh` when enabled.
- A full build takes many hours and ~30+ GB disk; SBU estimates improve after Binutils Pass 1 completes.
- After success, run `--cleanup`, reboot, and select the LFS entry in GRUB.

## License

Build scripts: same spirit as LFS — use at your own risk. LFS book content is © Linux From Scratch.
