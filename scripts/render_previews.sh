#!/usr/bin/env bash
# Render first-page PNG previews of the CV template for the README gallery.
#
# Pure typst (no python, no utpm) so it runs inside the pinned test Docker
# image (tests/Dockerfile) — which carries the font baseline (Roboto, Source
# Sans 3, Font Awesome 7, and Noto Sans CJK SC for the zh profile) but
# deliberately ships no python3. `just previews` and the update-previews
# workflow both drive this script inside that image, so the gallery renders
# from the exact fonts CI uses and can never drift from real template output.
#
# The package is registered for `@preview/brilliant-cv:<version>` by copying it
# under a --package-path tree — the same resolution `just link` sets up, minus
# the utpm/python dependency.
#
# Usage: scripts/render_previews.sh [out_dir] [profile ...]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ge 1 ]]; then
    OUT_DIR="$1"
    shift
else
    OUT_DIR="$ROOT/docs/previews"
fi

if [[ $# -ge 1 ]]; then
    PROFILES=("$@")
else
    # English is the Latin baseline, French adds accented Latin, Chinese
    # exercises the CJK path. Keep in sync with the README gallery.
    PROFILES=(en fr zh)
fi

# 150 ppi stays crisp on HiDPI screens without bloating the repo.
PPI=150

VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$ROOT/typst.toml" | head -1)"
if [[ -z "$VERSION" ]]; then
    echo "❌ could not read package version from typst.toml" >&2
    exit 1
fi

# Assemble a minimal package tree so cv.typ's `@preview/brilliant-cv:<version>`
# import resolves against the local source instead of the published release.
PKG_ROOT="$(mktemp -d)"
trap 'rm -rf "$PKG_ROOT"' EXIT
PKG_DIR="$PKG_ROOT/preview/brilliant-cv/$VERSION"
mkdir -p "$PKG_DIR"
cp "$ROOT/typst.toml" "$PKG_DIR/"
cp -R "$ROOT/src" "$PKG_DIR/"
cp -R "$ROOT/template" "$PKG_DIR/"

mkdir -p "$OUT_DIR"
for profile in "${PROFILES[@]}"; do
    out="$OUT_DIR/cv-$profile.png"
    typst compile \
        --package-path "$PKG_ROOT" \
        --root "$PKG_DIR/template" \
        --input "profile=$profile" \
        --pages 1 \
        --ppi "$PPI" \
        "$PKG_DIR/template/cv.typ" \
        "$out"
    echo "✅ rendered $out"
done
