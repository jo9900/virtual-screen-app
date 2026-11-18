# Virtual Screen

A menu bar app that gives a Mac without a monitor a HiDPI virtual display.

A Mac with no monitor attached gives remote desktop tools such as RustDesk a fixed 1920x1080
screen. Virtual Screen creates a virtual display at 1080p, 1440p, 1800p or 4K, makes it the main
display, and keeps it there.

- HiDPI (Retina) or 1x, switched from the menu bar
- Starts at login (optional), remembers your choice, recreates the display if macOS removes it
- Sandboxed; no driver, no `sudo`
- English, Japanese and Simplified Chinese

It uses `CGVirtualDisplay`, a private CoreGraphics class (the same one BetterDisplay and DeskPad
use). The display exists only while the app runs.

## Download

1. Download `VirtualScreen-<version>.dmg` from the
   [latest release](https://github.com/jo9900/virtual-screen-app/releases/latest).
2. Open it and drag **Virtual Screen** to **Applications**.
3. Open Virtual Screen from Applications. macOS asks once whether to open an app downloaded from
   the internet; choose **Open**.

The app is signed with Developer ID and notarized by Apple. It needs macOS 14 or later and runs on
Apple silicon and Intel Macs. It is not on the Mac App Store, because the App Store does not allow
private API.

To update, download the new DMG and replace the app in Applications.

## Common commands

```sh
# Remove the virtual display now (works over SSH)
pkill -x "Virtual Screen"

# Keep the virtual display off the next time the app starts (works over SSH)
defaults write io.github.jo9900.VirtualScreen isEnabled -bool false

# Undo that
defaults delete io.github.jo9900.VirtualScreen isEnabled
```

When the virtual display goes away, macOS falls back to its default headless 1920x1080 screen,
so RustDesk keeps working and the menu can be used to fix the settings.

If BetterDisplay also has a virtual screen, keep it disconnected, or the two compete for the main
display:

```sh
BD=/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
$BD get -identifiers                     # find the virtual screen's tagID
$BD set -tagID=3 -connected=off          # replace 3 with that tagID
```

## Resolutions

Resolutions are in points. HiDPI renders at twice the pixels, which is what a remote client
receives:

| Resolution | HiDPI pixels | 1x pixels |
| --- | --- | --- |
| 1920x1080 | 3840x2160 | 1920x1080 |
| 2560x1440 (default) | 5120x2880 | 2560x1440 |
| 3200x1800 | 6400x3600 | 3200x1800 |
| 3840x2160 | 7680x4320 | 3840x2160 |

## Limits

- Before login (at the login window) no app runs, so there is no virtual display. Enable automatic
  login for unattended use.
- `CGVirtualDisplay` is private API and may change in a future macOS release.

## Building

Needs Xcode 26 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
swift test --package-path Packages/VirtualScreenCore
xcodegen generate
open VirtualScreen.xcodeproj
```

Tested on macOS 27.2 with an Apple M4 Pro Mac mini.
