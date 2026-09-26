#!/bin/bash
set -euo pipefail

# Package an existing Release build with an ad hoc signature for manual distribution.
project_root="$(cd "$(dirname "$0")/.." && pwd)"
source_app="${1:?Usage: scripts/package-dmg.sh /path/to/Release/Sidekick.app}"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$source_app/Contents/Info.plist")"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$ ]]; then
    echo "Expected a stable or release-candidate version, found $version" >&2
    exit 1
fi
release_notes="$project_root/docs/releases/$version.md"
if [[ ! -f "$release_notes" ]]; then
    echo "Missing release notes: $release_notes" >&2
    exit 1
fi
if [[ "$(/usr/bin/lipo -archs "$source_app/Contents/MacOS/Sidekick")" != "arm64" ]]; then
    echo "Expected an Apple Silicon build." >&2
    exit 1
fi

staging="$(/usr/bin/mktemp -d /private/tmp/sidekick-release.XXXXXX)"
trap '/bin/rm -rf "$staging"' EXIT
image_root="$staging/image"
app="$image_root/Sidekick.app"
/bin/mkdir -p "$image_root" "$project_root/dist"
/usr/bin/ditto "$source_app" "$app"

# Sign bundled inference libraries and helper executables, including Resources.
while IFS= read -r -d '' binary; do
    if [[ "$binary" != "$app/Contents/MacOS/Sidekick" && "$(/usr/bin/file -b "$binary")" == *Mach-O* ]]; then
        /usr/bin/codesign --force --sign - --preserve-metadata=entitlements "$binary"
    fi
done < <(/usr/bin/find "$app/Contents" -type f -print0)

# Seal nested bundles after their contents, then seal the outer app.
while IFS= read -r -d '' bundle; do
    /usr/bin/codesign --force --sign - --preserve-metadata=entitlements "$bundle"
done < <(/usr/bin/find "$app/Contents" -depth -type d \( -name '*.framework' -o -name '*.xpc' -o -name '*.app' \) -print0)

/bin/cp "$project_root/Sidekick/Sidekick.entitlements" "$staging/entitlements.plist"
# A Developer Team application identifier cannot be claimed by an ad hoc build.
/usr/libexec/PlistBuddy -c 'Delete :com.apple.application-identifier' "$staging/entitlements.plist"
/usr/bin/codesign --force --sign - --entitlements "$staging/entitlements.plist" "$app"
/usr/bin/codesign --verify --deep --strict "$app"

/bin/ln -s /Applications "$image_root/Applications"
/bin/cp "$release_notes" "$image_root/Release Notes.md"
image_name="Sidekick-$version-arm64.dmg"
/usr/bin/hdiutil create -volname "Sidekick $version" -srcfolder "$image_root" -format UDZO -ov "$project_root/dist/$image_name"
/usr/bin/hdiutil verify "$project_root/dist/$image_name"
(
    cd "$project_root/dist"
    /usr/bin/shasum -a 256 "$image_name" > "$image_name.sha256"
)
echo "Created $project_root/dist/$image_name (ad hoc signed, not notarized)."
