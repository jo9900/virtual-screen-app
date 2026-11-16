# virtual-screen

Swift CLI that keeps a `CGVirtualDisplay` alive, plus shell scripts that install it as the
LaunchAgent `local.virtualscreen`. See README.md for usage.

## Layout

- `Sources/CGVirtualDisplayPrivate` — Objective-C header declaring the private CoreGraphics
  classes. The classes are exported in the SDK's `CoreGraphics.tbd`, so they link directly.
  Swift imports `applySettings:` as `apply(_:)`.
- `Sources/VirtualScreenCore` — pure logic (option parsing, resolutions, mode list); unit tested.
- `Sources/VirtualScreen` — the executable: creates the display, sets the mode, makes it main.
- `scripts/` — `install.sh` (builds release, writes the plist, bootstraps) and `uninstall.sh`.

## CGVirtualDisplay behavior (verified on macOS 27.2)

- `CGVirtualDisplayMode` sizes are pixels. With `hiDPI = 1`, macOS also offers each pixel
  mode at half size in points. A HiDPI mode is only marked usable for the desktop when its
  1x size is registered too, so `ModePlan` registers every preset at both 2x and 1x.
- macOS starts the display in the first mode of the list; the target mode goes first.
- When the virtual display comes online, the headless 1920x1080 fallback display disappears.
- The main display is the one at the global origin; `makeMain` shifts every display by the
  virtual display's offset.

## Testing on a headless machine

Display changes alter the live remote-desktop view. Check what is online first, disconnect
other virtual displays (e.g. BetterDisplay), and keep
`launchctl bootout gui/$(id -u)/local.virtualscreen` ready as the recovery path.

```sh
swift build && swift test
```
