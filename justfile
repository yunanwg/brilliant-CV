# Brilliant CV Development Justfile
# This file helps streamline development workflow for the brilliant-cv package

# Default recipe - show available commands
default:
    @just --list

# Complete development lifecycle with automatic cleanup
dev:
    @echo "🚀 Starting development lifecycle..."
    @echo "🔗 Linking workspace..."
    @just link || @echo "⚠️  Link failed or already linked"
    @echo "👁️  Starting watch mode (Ctrl+C to exit and cleanup)..."
    @echo "💡 When you exit, we'll build final version and cleanup automatically"
    @mkdir -p temp
    @trap 'echo "\n🛑 Stopping watch..."; just _dev-cleanup; exit 0' INT; \
    typst watch template/cv.typ temp/cv.pdf

# Internal cleanup function (don't call directly)
_dev-cleanup:
    @echo "🏗️  Building final version..."
    @mkdir -p temp
    @typst compile template/cv.typ temp/cv.pdf || @echo "⚠️  Build failed, but continuing cleanup..."
    @just unlink || @echo "⚠️  Unlink failed or already unlinked"
    @just clean || true
    @echo "✅ Development lifecycle complete!"
    @echo "💡 Your final CV is at temp/cv.pdf"

# Link local package for development
link:
    @echo "🔗 Linking local brilliant-cv package..."
    @utpm ws link --force --no-copy
    @echo "✅ Local package linked successfully!"
    @echo "💡 Typst will now use your local changes instead of cached version"

# Unlink local package (restore to using upstream version)
unlink:
    @echo "🔓 Unlinking local package..."
    @utpm pkg unlink --yes 2>/dev/null || @echo "💡 Package already unlinked or not found"
    @echo "✅ Local package unlinked - now using upstream version"

# Build CV template for testing
build:
    @echo "🏗️  Building CV template..."
    @mkdir -p temp
    @typst compile template/cv.typ temp/cv.pdf
    @echo "✅ CV built successfully at temp/cv.pdf"

# Build and open the result
open: build
    @echo "👀 Opening generated CV..."
    @open temp/cv.pdf 2>/dev/null || xdg-open temp/cv.pdf 2>/dev/null || echo "💡 Could not auto-open; find it at temp/cv.pdf"

# Watch for changes and rebuild automatically
watch:
    @echo "👁️  Watching for changes in template..."
    @mkdir -p temp
    typst watch template/cv.typ temp/cv.pdf

# Sync dependencies to latest versions
sync:
    @echo "🔄 Syncing dependencies..."
    @utpm ws sync
    @echo "✅ Dependencies synced!"

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    @find . -name "*.pdf" -not -path "./template/src/*" -delete
    @rm -rf temp/
    @echo "✅ Build artifacts cleaned"

# Reset development environment
reset: unlink clean
    @echo "🔄 Development environment reset"
    @echo "💡 Run 'just dev' to start development again"

# Prepare a version-bump PR. This never commits, tags, or pushes.
# Usage: just prepare-release 4.1.0
prepare-release version:
    @python3 scripts/release_contract.py bump "{{version}}"
    @just docs-generate
    @just check-version

# Check that the manifest, starter, and current documentation agree.
check-version:
    @python3 scripts/release_contract.py check-version

# Exercise the release guard itself against an isolated Git fixture.
release-contract-self-test:
    @python3 scripts/test_release_contract.py

# Assemble exactly what Typst Universe receives, then compile every starter.
package-check:
    #!/usr/bin/env bash
    set -euo pipefail
    PACKAGE_DIR=$(mktemp -d)/package
    python3 scripts/release_contract.py assemble "$PACKAGE_DIR"
    python3 scripts/release_contract.py smoke "$PACKAGE_DIR"

# Full pre-release contract. Tag only after this passes on the version-bump PR.
verify-release: check-version release-contract-self-test schema-check docs-check test fmt-check package-check

# Validate the editor-facing schema shipped with every initialized starter.
schema-check:
    @uv run --quiet --with jsonschema==4.25.1 python scripts/check_metadata_schema.py

# Refresh the auto-derived parts of the docs site:
#   - api-reference.md (from src/ typst doc-comments)
#   - assets/components/*.png (from tytanic component test refs — gives
#     components.md a "what does this look like" panel beside each example
#     code block, with zero re-rendering cost since the refs already exist).
docs-generate:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📖 Generating API reference..."
    uv run --quiet --no-project docs/web/generate-api-reference.py
    echo "🖼  Copying component render refs..."
    mkdir -p docs/web/docs/assets/components
    for dir in tests/components/*/; do
        name=$(basename "$dir")
        cp "$dir/ref/1.png" "docs/web/docs/assets/components/$name.png"
    done
    echo "✅ docs sources generated"

# Regenerate the API reference and compile every public Typst example.
docs-check: schema-check docs-generate
    @python3 scripts/check_docs_snippets.py

# Serve documentation site locally
docs-serve: docs-generate
    @echo "📖 Starting docs server at http://localhost:8000..."
    cd docs/web && uv run --with mkdocs-material --with mkdocs-glightbox mkdocs serve

# Build documentation site
docs-build: docs-check
    @echo "📖 Building docs site..."
    cd docs/web && uv run --with mkdocs-material --with mkdocs-glightbox mkdocs build
    @echo "✅ Docs built at docs/web/site/"

# --- Test suite (Docker-based, Linux baseline) -----------------------------
#
# Visual tests run inside the same Linux Docker image (tests/Dockerfile) on
# both maintainer machines and CI. Persistent refs use fonts verified stable
# across the two ARM hosts. The image bundles typst 0.15.1, tytanic 0.4.1,
# typstyle 0.15.0, Source Sans 3, Roboto, Font Awesome 7, Noto CJK SC.
#
# Compile-only tests (panics + units) don't need Docker — they run native
# via `just test-fast` for sub-second inner loops. Visual tests are
# `just test`. After intentional layout changes run `just test-update`
# to regenerate refs (in Docker, so CI sees the same pixels).

DOCKER_IMAGE := "brilliant-cv-test"
# arm64 only — see tests/Dockerfile header. Cross-arch via Rosetta/QEMU
# drifts FreeType pixels, so the maintainer's Mac and the CI runner
# (ubuntu-24.04-arm) both run native arm64.
DOCKER_PLATFORM := "linux/arm64"

# Build the test image (cached after first run; rebuild on Dockerfile change)
test-image:
    @docker build --platform={{DOCKER_PLATFORM}} -t {{DOCKER_IMAGE}} -f tests/Dockerfile .

# Run a command inside the test image with the workspace mounted
_test-docker CMD: test-image
    @docker run --rm --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}} bash -c "{{CMD}}"

# Run the full test suite — tytanic visual + panic smoke tests in Docker
test: test-image
    @bash tests/guards.sh
    @docker run --rm --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}} bash -c "tt run --no-fail-fast && bash tests/panics/run.sh"

# Compile-only tests (panics + units) — runs native, no Docker, sub-second
#
# No `link` prerequisite: units/ and panics/ fixtures use root-relative
# imports (`/src/...`, `/tests/...`), never `@preview/brilliant-cv:...`, so
# utpm's local package link is not needed here (confirmed via
# `grep -r '@preview' tests/units tests/panics` — no matches).
test-fast:
    @tt run --no-fail-fast -e 'glob:"units/*"'
    @bash tests/panics/run.sh
    @bash tests/guards.sh

# Run only the panic-fixture shell-script smoke tests (native)
test-panics:
    @bash tests/panics/run.sh

# Filter tests by tytanic test-set glob (in Docker — visual diff aware)
test-filter PAT: test-image
    @docker run --rm --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}} tt run --no-fail-fast -e 'glob:"{{PAT}}"'

# Regenerate ref PNGs in the pinned Docker toolchain
test-update: test-image
    @docker run --rm --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}} tt update --no-fail-fast

# Drop into an interactive shell inside the test image (debugging aid)
test-shell: test-image
    @docker run --rm -it --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}}

# --- Code quality (typstyle) ----------------------------------------------

# Format all Typst sources in place (native — typstyle is pure-Rust, no fonts)
fmt:
    @typstyle -i src template tests
    @echo "✅ Formatted src/, template/, tests/"

# Check formatting (CI gate; runs in Docker for version pin consistency)
fmt-check: test-image
    @docker run --rm --platform={{DOCKER_PLATFORM}} -v "$(pwd):/workspace" {{DOCKER_IMAGE}} typstyle --check src template tests

# --- Deprecated -----------------------------------------------------------

# Compare PDFs for visual regression testing (deprecated — use `just test`).
# Kept for one release as a fallback for spot-checking at PDF level.
# Usage: just compare <baseline.pdf> <new.pdf>
compare baseline new:
    @echo "⚠️  just compare is deprecated. Prefer `just test` (PNG-level via tytanic)."
    @echo "🔍 Comparing PDFs..."
    @mkdir -p temp/compare
    @if diff-pdf "{{baseline}}" "{{new}}"; then \
        echo "✅ PDFs are IDENTICAL - no visual changes"; \
    else \
        echo "⚠️  PDFs DIFFER - generating visual diff..."; \
        diff-pdf --output-diff=temp/compare/diff.pdf "{{baseline}}" "{{new}}" || true; \
        echo "📄 Visual diff saved to temp/compare/diff.pdf"; \
        echo "👀 Opening files for review..."; \
        open "{{baseline}}" "{{new}}" temp/compare/diff.pdf 2>/dev/null || xdg-open "{{baseline}}" "{{new}}" temp/compare/diff.pdf 2>/dev/null || echo "💡 Could not auto-open; check {{baseline}}, {{new}}, and temp/compare/diff.pdf manually"; \
    fi

# Build and compare against a baseline PDF (deprecated — use `just test`)
compare-build baseline:
    @echo "⚠️  just compare-build is deprecated. Prefer `just test`."
    @echo "🏗️  Building current version..."
    @just build
    @just compare "{{baseline}}" temp/cv.pdf
