# Virtual Screen

macOS menu bar app that keeps a `CGVirtualDisplay` alive as the main display, for Macs without a
monitor. Targets the Mac App Store (sandboxed). Design: `docs/superpowers/specs/`.

## Repositories

- `origin` is the private repo `jo9900/virtual-screen-app`. All work is pushed there.
- The public repo `jo9900/virtual-screen` holds only the original CLI and is frozen. Never push to
  it; it is not a remote here.
- The public repo `jo9900/virtual-screen-support` hosts the App Store support and privacy pages.

## Layout

- `project.yml` — XcodeGen spec. Run `xcodegen generate` after changing it or adding files; the
  `.xcodeproj` is generated and not committed.
- `App/` — the app target (AppKit, no SwiftUI): `DisplayController` owns the display,
  `StatusMenu` builds the menu on every open, `AppSettings` wraps UserDefaults (its keys are the
  documented SSH recovery interface — keep them stable), `LoginItem` wraps `SMAppService.mainApp`.
- `App/AppIcon.icon` — Icon Composer document (SVG layers + `icon.json`); actool compiles it.
- `App/Localizable.xcstrings` — every user-facing string, in `en`, `ja`, `zh-Hans`.
- `Packages/VirtualScreenCore` — local package: private API header (`CGVirtualDisplayPrivate`),
  resolutions, `ModePlan`, `DisplaySelection`, `VirtualDisplay`, `DisplayConfigurator`. Unit tested.
- `AppStore/` — listing text per language (`metadata/`), screenshots (`screenshots/`, regenerate
  with `swift AppStore/screenshots/compose.swift` from window-only captures in `raw/`), export
  options, and `CHECKLIST.md` for App Store Connect.
- `scripts/release.sh export|upload` — tests, archives (team `54BTJHJKUU`, automatic signing) and
  exports or uploads to App Store Connect. Bump `CURRENT_PROJECT_VERSION` in `project.yml` first.

Screenshots must never show the desktop or personal data: capture single windows with
`screencapture -l <windowID>`, never the full screen or System Settings (it shows the account name).

## CGVirtualDisplay behavior (verified on macOS 27.2)

- The classes are exported in the SDK's `CoreGraphics.tbd`, so the header links directly. Swift
  imports `applySettings:` as `apply(_:)`.
- `CGVirtualDisplayMode` sizes are pixels. With `hiDPI = 1`, macOS also offers each pixel mode at
  half size in points. A HiDPI mode is only marked usable for the desktop when its 1x size is
  registered too, so `ModePlan` registers every preset at both 2x and 1x.
- macOS starts the display in the first mode of the list; the target mode goes first.
- When the virtual display comes online, the headless 1920x1080 fallback display disappears.
- The main display is the one at the global origin; `makeMain` shifts every display by the virtual
  display's offset.
- Works inside the App Sandbox. `defaults write io.github.jo9900.VirtualScreen ...` from a shell
  reaches the sandbox container's preferences.

## Build and test

```sh
swift test --package-path Packages/VirtualScreenCore
xcodegen generate
xcodebuild -project VirtualScreen.xcodeproj -scheme VirtualScreen -configuration Debug \
  -derivedDataPath .build/DerivedData build
```

Debug builds are ad-hoc signed. Launch arguments: `-didAskAboutLoginItem YES` skips the login
prompt; `-ScreenshotMenu YES` (Debug only) opens the menu after launch for screenshots.

## Testing on a headless machine

Display changes alter the live remote-desktop view. Check what is online first and disconnect other
virtual displays (e.g. BetterDisplay). Recovery: `pkill -x "Virtual Screen"`.
