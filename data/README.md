# LFS source download lists

Bundled copies of the LFS 13.0 download lists and checksums (not read from the book tree at build time).

| File | Purpose |
|------|---------|
| `wget-list-systemd` | Sources + patches for **systemd** edition (used by default) |
| `wget-list` | Sources + patches for **sysv** edition |
| `md5sums` | Verify downloads in `$LFS/sources` |

## URL fixes vs book `13.0/`

Verified with `wget --spider` on the bundled lists (May 2026):

- **All `ftpmirror.gnu.org` GNU packages** → `https://ftp.gnu.org/gnu/...` (same paths; `ftpmirror` often returns wget exit 8)
- **xz-5.8.2** → fixed `github.com//tukaani-project` → `github.com/tukaani-project`
- **lfs-bootscripts** (sysv list) → `.../downloads/stable/...` instead of `.../downloads/13.0/...`

Checksums in `md5sums` are unchanged (same tarballs, different mirrors).
