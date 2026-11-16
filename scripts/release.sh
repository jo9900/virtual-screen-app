#!/bin/bash
# Archives a Release build and either exports an App Store package or uploads it.
# Usage: scripts/release.sh export|upload
# Bump CURRENT_PROJECT_VERSION (and MARKETING_VERSION for a new version) in project.yml first;
# App Store Connect rejects a build number it has already received.
set -euo pipefail

MODE="${1:-}"
case "$MODE" in
    export) OPTIONS=AppStore/ExportOptions.plist ;;
    upload) OPTIONS=AppStore/ExportOptions-upload.plist ;;
    *) echo "usage: $0 export|upload" >&2; exit 64 ;;
esac

cd "$(dirname "$0")/.."
ARCHIVE=.build/VirtualScreen.xcarchive

swift test --package-path Packages/VirtualScreenCore
xcodegen generate
rm -rf "$ARCHIVE" .build/export
xcodebuild -project VirtualScreen.xcodeproj -scheme VirtualScreen -configuration Release \
    -derivedDataPath .build/DerivedData -archivePath "$ARCHIVE" archive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath .build/export \
    -exportOptionsPlist "$OPTIONS" -allowProvisioningUpdates

echo "Done ($MODE). Output: .build/export"
