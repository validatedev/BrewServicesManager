#!/bin/bash
set -e

# ============================================================================
# Brew Services Manager Release Script
# ============================================================================
# This script automates the release process:
# 1. Creates a DMG from the exported app
# 2. Signs it with Sparkle's EdDSA key
# 3. Updates appcast.xml
# 4. Creates a GitHub release draft
#
# Prerequisites:
# - Xcode archive exported with Developer ID signing
# - Sparkle EdDSA private key in Keychain (from generate_keys)
# - GitHub CLI (gh) installed and authenticated
# - App notarized (optional but recommended)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APPCAST_FILE="$PROJECT_ROOT/appcast.xml"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"
APP_NAME="BrewServicesManager"
GITHUB_REPO="validatedev/BrewServicesManager"
NOTARIZATION_PROFILE="BrewServicesManager-Notarization"

# Find Sparkle tools
SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Sparkle/bin" -type d 2>/dev/null | head -1)

if [ -z "$SPARKLE_BIN" ]; then
    echo "Error: Sparkle tools not found. Build the project in Xcode first."
    exit 1
fi

SIGN_UPDATE="$SPARKLE_BIN/sign_update"

# ============================================================================
# Functions
# ============================================================================

print_usage() {
    echo "Usage: $0 <version> <app-path>"
    echo ""
    echo "Arguments:"
    echo "  version   Version string (e.g., 1.1, 2.0)"
    echo "  app-path  Path to the exported .app bundle"
    echo ""
    echo "Example:"
    echo "  $0 1.1 ~/Desktop/BrewServicesManager.app"
    echo ""
    echo "Before running this script:"
    echo "  1. Archive in Xcode (Product > Archive)"
    echo "  2. Distribute > Developer ID > Export"
    echo "  3. (Recommended) Notarize the app"
}

notarize_app() {
    local app_path="$1"

    echo "Submitting for notarization..."
    echo "This may take a few minutes..."

    # Create a temporary zip for notarization
    local temp_zip=$(mktemp).zip
    ditto -c -k --keepParent "$app_path" "$temp_zip"

    # Submit and wait
    xcrun notarytool submit "$temp_zip" \
        --keychain-profile "$NOTARIZATION_PROFILE" \
        --wait

    rm "$temp_zip"

    # Staple the ticket to the app
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$app_path"

    echo "Notarization complete!"
}

create_dmg() {
    local app_path="$1"
    local dmg_path="$2"
    local volume_name="$APP_NAME"

    echo "Creating DMG..."

    # Create temporary directory for DMG contents
    local temp_dir=$(mktemp -d)
    cp -R "$app_path" "$temp_dir/"
    ln -s /Applications "$temp_dir/Applications"

    # Create DMG
    hdiutil create -volname "$volume_name" \
        -srcfolder "$temp_dir" \
        -ov -format UDZO \
        "$dmg_path"

    rm -rf "$temp_dir"
    echo "Created: $dmg_path"
}

sign_update() {
    local dmg_path="$1"

    echo "Signing update with EdDSA..."
    local signature=$("$SIGN_UPDATE" "$dmg_path" 2>&1 | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)

    if [ -z "$signature" ]; then
        # Try alternate output format
        signature=$("$SIGN_UPDATE" "$dmg_path" 2>&1 | tail -1)
    fi

    echo "$signature"
}

get_file_size() {
    stat -f%z "$1"
}

extract_changelog() {
    local version="$1"

    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo "No CHANGELOG.md found"
        return
    fi

    # Extract section for the specified version
    # Matches from "## [version]" until the next "## [" or end of file
    awk -v ver="$version" '
    /^## \[/ {
        if (found) exit
        if ($0 ~ "\\[" ver "\\]") found=1
        next
    }
    found { print }
    ' "$CHANGELOG_FILE" | sed '/^$/N;/^\n$/d'  # Remove excess blank lines
}

update_changelog_version() {
    local version="$1"
    local today=$(date +%Y-%m-%d)

    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo "No CHANGELOG.md found, skipping changelog update"
        return
    fi

    echo "Updating CHANGELOG.md..."

    # Get the previous version from the first versioned header (not Unreleased)
    local prev_version=$(grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$CHANGELOG_FILE" | head -1 | grep -o '\[[0-9]*\.[0-9]*\.[0-9]*\]' | tr -d '[]')

    if [ -z "$prev_version" ]; then
        echo "Warning: No previous version found in CHANGELOG.md"
        echo "This appears to be the first release. Skipping comparison link."
        prev_version=""
    fi

    # Create temp file
    local temp_file=$(mktemp)

    awk -v ver="$version" -v date="$today" '
    # Replace [Unreleased] header with version and date, add new Unreleased
    /^## \[Unreleased\]/ {
        print "## [Unreleased]"
        print ""
        print "## [" ver "] - " date
        next
    }
    { print }
    ' "$CHANGELOG_FILE" > "$temp_file"

    # Update the links at the bottom
    # Replace [unreleased] link
    sed -i '' "s|\[unreleased\]:.*|[unreleased]: https://github.com/$GITHUB_REPO/compare/v$version...HEAD|" "$temp_file"

    # Add new version link before the first version link
    if [ -n "$prev_version" ]; then
        local new_link="[$version]: https://github.com/$GITHUB_REPO/compare/v$prev_version...v$version"

        awk -v new_link="$new_link" '
        /^\[[0-9]+\.[0-9]+\.[0-9]+\]:/ && !inserted {
            print new_link
            inserted = 1
        }
        { print }
        ' "$temp_file" > "${temp_file}.2"

        mv "${temp_file}.2" "$CHANGELOG_FILE"
        rm -f "$temp_file"
    else
        # First release - just add the release tag link at the end
        echo "[$version]: https://github.com/$GITHUB_REPO/releases/tag/v$version" >> "$temp_file"
        mv "$temp_file" "$CHANGELOG_FILE"
    fi

    echo "Updated CHANGELOG.md: [Unreleased] → [$version] - $today"
}

get_bundle_version() {
    local app_path="$1"
    /usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$app_path/Contents/Info.plist"
}

update_appcast() {
    local version="$1"
    local bundle_version="$2"
    local dmg_url="$3"
    local signature="$4"
    local file_size="$5"
    local pub_date=$(date -R)

    echo "Updating appcast.xml..."

    # Create new item entry
    local new_item="    <item>
      <title>Version $version</title>
      <sparkle:version>$bundle_version</sparkle:version>
      <sparkle:shortVersionString>$version</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
      <pubDate>$pub_date</pubDate>
      <enclosure
        url=\"$dmg_url\"
        sparkle:edSignature=\"$signature\"
        length=\"$file_size\"
        type=\"application/octet-stream\" />
    </item>"

    # Insert before closing </channel> tag
    # Use a temp file for sed compatibility
    local temp_file=$(mktemp)
    awk -v item="$new_item" '
    /<\/channel>/ {
        print item
        print ""
    }
    { print }
    ' "$APPCAST_FILE" > "$temp_file"
    mv "$temp_file" "$APPCAST_FILE"

    echo "Updated: $APPCAST_FILE"
}

create_git_tag() {
    local version="$1"
    local tag="v$version"

    # Check if tag already exists
    if git rev-parse "$tag" >/dev/null 2>&1; then
        echo "Tag $tag already exists"
        return 0
    fi

    echo "Creating git tag: $tag"
    git tag -a "$tag" -m "Release $version"
}

create_github_release() {
    local version="$1"
    local dmg_path="$2"

    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) not installed. Skipping GitHub release."
        echo "Install with: brew install gh"
        return
    fi

    echo "Creating GitHub release draft..."

    # Extract changelog for this version
    local changelog=$(extract_changelog "$version")

    if [ -z "$changelog" ]; then
        changelog="- See CHANGELOG.md for details"
        echo "Warning: No changelog entry found for version $version"
    fi

    local release_notes="## What's New

$changelog

---
*This release includes automatic updates via Sparkle.*"

    gh release create "v$version" \
        --repo "$GITHUB_REPO" \
        --title "Version $version" \
        --notes "$release_notes" \
        --draft \
        "$dmg_path"

    echo "GitHub release draft created: v$version"
}

# ============================================================================
# Main
# ============================================================================

if [ $# -lt 2 ]; then
    print_usage
    exit 1
fi

VERSION="$1"
APP_PATH="$2"

# Validate inputs
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at: $APP_PATH"
    exit 1
fi

if [[ ! "$APP_PATH" == *.app ]]; then
    echo "Error: Path must be a .app bundle"
    exit 1
fi

# Get bundle version from app
BUNDLE_VERSION=$(get_bundle_version "$APP_PATH")
echo "App version: $VERSION (build $BUNDLE_VERSION)"

# Notarization
echo ""
read -p "Notarize the app? (recommended) (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    notarize_app "$APP_PATH"
fi

# Create output directory
OUTPUT_DIR="$PROJECT_ROOT/releases"
mkdir -p "$OUTPUT_DIR"

DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"
DMG_URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/$DMG_NAME"

# Create DMG
create_dmg "$APP_PATH" "$DMG_PATH"

# Sign with EdDSA
SIGNATURE=$(sign_update "$DMG_PATH")
if [ -z "$SIGNATURE" ]; then
    echo "Error: Failed to sign update"
    exit 1
fi
echo "Signature: ${SIGNATURE:0:20}..."

# Get file size
FILE_SIZE=$(get_file_size "$DMG_PATH")
echo "File size: $FILE_SIZE bytes"

# Update changelog (convert [Unreleased] to version)
update_changelog_version "$VERSION"

# Update appcast
update_appcast "$VERSION" "$BUNDLE_VERSION" "$DMG_URL" "$SIGNATURE" "$FILE_SIZE"

# Commit and tag
echo ""
echo "The following files have been modified:"
git status --short "$APPCAST_FILE" "$CHANGELOG_FILE" 2>/dev/null || true
echo ""
read -p "Commit release changes and create tag v$VERSION? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Stage release files
    git add "$APPCAST_FILE"
    [ -f "$CHANGELOG_FILE" ] && git add "$CHANGELOG_FILE"

    # Commit
    git commit -m "Release $VERSION"

    # Create tag
    create_git_tag "$VERSION"

    # Push everything
    echo ""
    read -p "Push commit and tag to remote? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin HEAD
        git push origin "v$VERSION"
        echo "Pushed commit and tag to origin"
    fi
fi

# Create GitHub release
echo ""
read -p "Create GitHub release draft? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    create_github_release "$VERSION" "$DMG_PATH"
fi

echo ""
echo "============================================"
echo "Release preparation complete!"
echo "============================================"
echo ""
echo "Files:"
echo "  DMG: $DMG_PATH"
echo "  Appcast: $APPCAST_FILE"
echo "  Changelog: $CHANGELOG_FILE"
echo ""
echo "If you skipped any steps, you may need to:"
echo "  - Commit and push changes manually"
echo "  - Create git tag: git tag -a v$VERSION -m 'Release $VERSION'"
echo "  - Publish the GitHub release draft"
echo ""
