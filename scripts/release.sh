#!/bin/bash
# Archives a Release build, then:
#   dmg     signs it with Developer ID, has Apple notarize it, and packs the notarized app into
#           .build/dmg/VirtualScreen-<version>.dmg for GitHub Releases
#   export  exports an App Store package to .build/export
#   upload  uploads an App Store build to App Store Connect
# Usage: scripts/release.sh dmg|export|upload
# Signing and notarization use the Apple account signed in to Xcode (team 54BTJHJKUU).
set -euo pipefail

MODE="${1:-}"
case "$MODE" in
    dmg) OPTIONS=scripts/ExportOptions-developer-id.plist ;;
    export) OPTIONS=AppStore/ExportOptions.plist ;;
    upload) OPTIONS=AppStore/ExportOptions-upload.plist ;;
    *) echo "usage: $0 dmg|export|upload" >&2; exit 64 ;;
esac

cd "$(dirname "$0")/.."
ARCHIVE=.build/VirtualScreen.xcarchive
APP_NAME="Virtual Screen"

swift test --package-path Packages/VirtualScreenCore
xcodegen generate
rm -rf "$ARCHIVE" .build/export
xcodebuild -project VirtualScreen.xcodeproj -scheme VirtualScreen -configuration Release \
    -derivedDataPath .build/DerivedData -archivePath "$ARCHIVE" archive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath .build/export \
    -exportOptionsPlist "$OPTIONS" -allowProvisioningUpdates

if [ "$MODE" != dmg ]; then
    echo "Done ($MODE). Output: .build/export"
    exit 0
fi

# The export above submitted the app for notarization; exporting the notarized app fails until
# Apple has accepted it.
rm -rf .build/notarized
for attempt in $(seq 1 60); do
    if xcodebuild -exportNotarizedApp -archivePath "$ARCHIVE" -exportPath .build/notarized \
        > .build/notarized.log 2>&1; then
        break
    fi
    if [ "$attempt" -eq 60 ]; then
        cat .build/notarized.log >&2
        echo "Notarization did not finish within 30 minutes." >&2
        exit 1
    fi
    sleep 30
done

APP=".build/notarized/$APP_NAME.app"
xcrun stapler validate "$APP"
spctl --assess --type execute "$APP"

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")
STAGING=.build/dmg/staging
DMG=".build/dmg/VirtualScreen-$VERSION.dmg"
rm -rf .build/dmg
mkdir -p "$STAGING"
ditto "$APP" "$STAGING/$APP_NAME.app"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -fs HFS+ -format UDZO -ov "$DMG"
rm -rf "$STAGING"

echo "Done (dmg). Output: $DMG"
