#!/usr/bin/env bash
# Container entrypoint. Registers the workspace as @preview/brilliant-cv:<v>
# (equivalent of `just link` / `utpm ws link --no-copy`) so profile modules
# that import the published package resolve to /workspace, then execs args.
set -euo pipefail

if [[ -f /workspace/typst.toml ]]; then
    PKG_NAME=$(awk -F'"' '/^name *=/{print $2; exit}' /workspace/typst.toml)
    PKG_VERSION=$(awk -F'"' '/^version *=/{print $2; exit}' /workspace/typst.toml)
    PKG_DIR="${HOME:-/root}/.local/share/typst/packages/preview/${PKG_NAME}/${PKG_VERSION}"
    if [[ ! -L "$PKG_DIR" ]]; then
        mkdir -p "$(dirname "$PKG_DIR")"
        ln -sf /workspace "$PKG_DIR"
    fi
fi

exec "$@"
