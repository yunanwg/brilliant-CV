# Brilliant CV Development Justfile
# This file helps streamline development workflow for the brilliant-cv package

# Default recipe - show available commands
default:
    @just --list

# Install UTPM if not already installed
install-utpm:
    @echo "📥 Installing UTPM..."
    cargo install utpm
    @echo "✅ UTPM installed successfully!"

# Setup development environment by linking local package
dev-setup:
    @echo "🔧 Setting up development environment..."
    @echo "📦 Linking local brilliant-cv package..."
    utpm ws link --force
    @echo "✅ Development setup complete!"
    @echo "💡 You can now test local changes without cache conflicts"

# Check if UTPM is installed
check-utpm:
    @echo "🔍 Checking UTPM installation..."
    @if command -v utpm >/dev/null 2>&1; then \
        echo "✅ UTPM is installed ($(utpm --version))"; \
    else \
        echo "❌ UTPM is not installed. Run 'just install-utpm' to install it"; \
        exit 1; \
    fi

# Link local package for development (with UTPM check)
link: check-utpm
    @echo "🔗 Linking local brilliant-cv package..."
    utpm ws link --force
    @echo "✅ Local package linked successfully!"
    @echo "💡 Typst will now use your local changes instead of cached version"

# Unlink local package (restore to using upstream version)
unlink: check-utpm
    @echo "🔓 Unlinking local package..."
    utpm pkg unlink brilliant-cv
    @echo "✅ Local package unlinked - now using upstream version"

# Build CV template for testing
build:
    @echo "🏗️  Building CV template..."
    cd template && typst compile cv.typ cv.pdf
    @echo "✅ CV built successfully at template/cv.pdf"

# Build CV template and open the result
build-and-open: build
    @echo "👀 Opening generated CV..."
    open template/cv.pdf

# Watch for changes and rebuild automatically
watch:
    @echo "👁️  Watching for changes in template..."
    cd template && typst watch cv.typ cv.pdf

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    find . -name "*.pdf" -not -path "./template/src/*" -delete
    @echo "✅ Build artifacts cleaned"

# Show package information
info: check-utpm
    @echo "📋 Package information:"
    @echo "Package: brilliant-cv"
    @echo "Version: $(grep '^version = ' typst.toml | cut -d'"' -f2)"
    @echo ""
    @echo "🔍 UTPM package status:"
    utpm pkg list | grep -E "(brilliant-cv|Namespace)" || echo "Package not found in local storage"

# List all local packages managed by UTPM
list-packages: check-utpm
    @echo "📦 All local packages:"
    utpm pkg list

# Sync dependencies to latest versions
sync: check-utpm
    @echo "🔄 Syncing dependencies..."
    utpm ws sync
    @echo "✅ Dependencies synced!"

# Install dependencies from typst.toml
install: check-utpm
    @echo "📥 Installing dependencies..."
    utpm ws install
    @echo "✅ Dependencies installed!"

# Bump package version (patch)
bump-patch: check-utpm
    @echo "⬆️  Bumping patch version..."
    utpm ws bump patch
    @echo "✅ Version bumped!"

# Bump package version (minor)
bump-minor: check-utpm
    @echo "⬆️  Bumping minor version..."
    utpm ws bump minor
    @echo "✅ Version bumped!"

# Bump package version (major)
bump-major: check-utpm
    @echo "⬆️  Bumping major version..."
    utpm ws bump major
    @echo "✅ Version bumped!"

# Test the CV template with local changes
test: link build
    @echo "🧪 Testing CV template with local changes..."
    @echo "✅ Test complete! Check template/cv.pdf for results"

# Full development workflow: link, build, and watch
dev: link build watch

# Reset development environment
reset: unlink clean
    @echo "🔄 Development environment reset"
    @echo "💡 Run 'just dev-setup' to start development again"
