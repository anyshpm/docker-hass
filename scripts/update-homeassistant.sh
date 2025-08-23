#!/bin/bash

# Home Assistant Version Update Script
# This script checks for the latest Home Assistant version and updates the Dockerfile
# Usage: ./scripts/update-homeassistant.sh [--force] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKERFILE="Dockerfile"
README="README.md"
FORCE_UPDATE=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force] [--dry-run]"
            echo "  --force    Force update even if version is the same"
            echo "  --dry-run  Show what would be done without making changes"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required files exist
if [ ! -f "$DOCKERFILE" ]; then
    print_error "Dockerfile not found in current directory"
    exit 1
fi

print_status "🔍 Checking Home Assistant versions..."

# Get current version from Dockerfile
CURRENT_VERSION=$(grep -oP 'FROM homeassistant/home-assistant:\K[^\s]+' "$DOCKERFILE")
if [ -z "$CURRENT_VERSION" ]; then
    print_error "Could not extract current version from Dockerfile"
    print_error "Please verify that Dockerfile contains a valid FROM line with homeassistant/home-assistant image"
    exit 1
fi
print_status "Current version: $CURRENT_VERSION"

# Get latest version from Docker Hub
print_status "Fetching latest version from Docker Hub..."
LATEST_VERSION=$(curl -s "https://registry.hub.docker.com/v2/repositories/homeassistant/home-assistant/tags?page_size=100&ordering=-last_updated" | \
    jq -r '.results[] | select(.name | test("^[0-9]{4}\\.[0-9]+\\.[0-9]+$")) | .name' | \
    sort -V | tail -1)

# Validate that we got a valid version
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
    print_error "Failed to fetch latest Home Assistant version from Docker Hub API"
    echo "This could be due to:"
    echo "  - Docker Hub API is down or rate limiting"
    echo "  - Network connectivity issues"
    echo "  - Changes in Docker Hub API response format"
    echo "  - No valid semantic version tags found"
    exit 1
fi

# Additional validation for version format
if ! echo "$LATEST_VERSION" | grep -qE '^[0-9]{4}\.[0-9]+\.[0-9]+$'; then
    print_error "Invalid version format detected: '$LATEST_VERSION'"
    echo "Expected format: YYYY.MM.DD (e.g., 2025.4.1)"
    exit 1
fi
print_status "Latest version: $LATEST_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ] && [ "$FORCE_UPDATE" = false ]; then
    print_success "✅ Already up to date! Current version $CURRENT_VERSION is the latest."
    exit 0
fi

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    print_status "🔄 Update available: $CURRENT_VERSION -> $LATEST_VERSION"
elif [ "$FORCE_UPDATE" = true ]; then
    print_warning "🔄 Force update requested for version $LATEST_VERSION"
fi

if [ "$DRY_RUN" = true ]; then
    print_warning "🧪 DRY RUN MODE - No changes will be made"
    echo "Would update:"
    echo "  - Dockerfile: homeassistant/home-assistant:$CURRENT_VERSION -> homeassistant/home-assistant:$LATEST_VERSION"
    if [ -f "$README" ]; then
        echo "  - README badges with new version"
    fi
    exit 0
fi

# Create backup
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$DOCKERFILE" "$BACKUP_DIR/"
if [ -f "$README" ]; then
    cp "$README" "$BACKUP_DIR/"
fi
print_status "📦 Backup created in $BACKUP_DIR/"

# Update Dockerfile
print_status "🛠️ Updating Dockerfile..."
sed -i.bak "s/FROM homeassistant\/home-assistant:$CURRENT_VERSION/FROM homeassistant\/home-assistant:$LATEST_VERSION/g" "$DOCKERFILE"

# Verify the change
if grep -q "FROM homeassistant/home-assistant:$LATEST_VERSION" "$DOCKERFILE"; then
    print_success "✅ Dockerfile updated successfully"
    rm -f "$DOCKERFILE.bak"
else
    print_error "❌ Failed to update Dockerfile"
    mv "$DOCKERFILE.bak" "$DOCKERFILE"
    exit 1
fi

# Update README if it exists
if [ -f "$README" ]; then
    print_status "📝 Updating README badges..."
    sed -i.bak "s/Home%20Assistant-[0-9]\{4\}\.[0-9]\+\.[0-9]\+-blue/Home%20Assistant-${LATEST_VERSION}-blue/g" "$README"
    rm -f "$README.bak"
    print_success "✅ README updated successfully"
fi

# Test build (optional, can be skipped with --skip-build)
if command -v docker &> /dev/null; then
    print_status "🧪 Testing Docker build..."
    if docker build --no-cache -t test-homeassistant:$LATEST_VERSION . > /dev/null 2>&1; then
        print_success "✅ Docker build test passed"
        docker rmi test-homeassistant:$LATEST_VERSION > /dev/null 2>&1 || true
    else
        print_warning "⚠️ Docker build test failed - please review the changes manually"
    fi
else
    print_warning "⚠️ Docker not found - skipping build test"
fi

# Show summary
echo ""
print_success "🎉 Update completed successfully!"
echo ""
echo "Summary of changes:"
echo "  📄 Dockerfile: homeassistant/home-assistant:$CURRENT_VERSION -> homeassistant/home-assistant:$LATEST_VERSION"
if [ -f "$README" ]; then
    echo "  📖 README: Updated version badges"
fi
echo "  📦 Backup: Created in $BACKUP_DIR/"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Test the build: docker build -t test ."
echo "  3. Commit the changes: git add -A && git commit -m \"Update Home Assistant to $LATEST_VERSION\""
echo "  4. Push to repository: git push"
echo ""