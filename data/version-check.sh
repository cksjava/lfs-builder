#!/bin/bash
# Delegate to the canonical script at the repository root.
exec "$(cd "$(dirname "$0")/.." && pwd)/version-check.sh" "$@"
