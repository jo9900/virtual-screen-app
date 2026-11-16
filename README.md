# virtual-screen

A free, minimal virtual display for headless Macs.

A Mac with no monitor attached gives remote desktop tools such as RustDesk a
fixed 1920x1080 screen. `virtual-screen` creates a HiDPI virtual display at
1080p, 1440p, 1800p or 4K, makes it the main display, and keeps it there. It
covers the virtual screen feature of BetterDisplay in about 400 lines of Swift.

- HiDPI (Retina) or 1x modes, switchable in System Settings > Displays
- Runs as a per-user LaunchAgent: starts at login, restarts after a crash
- No `sudo`, no kernel extension, no driver; uninstall removes two files
- Idles at about 10 MB of memory and 0% CPU

It uses `CGVirtualDisplay`, a private CoreGraphics class (the same one
BetterDisplay and DeskPad use). The display exists only while the process
runs, which is why it is installed as a LaunchAgent.

Tested on macOS 27.2 with an Apple M4 Pro Mac mini. Building needs Xcode 16 or
later (Swift 6).

## Common commands

Run the `./scripts/...` commands from this directory.

```sh
# Install, or reinstall with another resolution (run from a desktop session, not SSH)
./scripts/install.sh                          # 2560x1440 HiDPI (default)
./scripts/install.sh --resolution 3840x2160   # 4K HiDPI
./scripts/install.sh --resolution 2560x1440 --no-hidpi

# Check whether it is running
launchctl print gui/$(id -u)/local.virtualscreen | grep -E '^\t(state|pid) ='

# Follow the log
tail -f ~/Library/Logs/virtual-screen.log

# Restart (recreates the display)
launchctl kickstart -k gui/$(id -u)/local.virtualscreen

# Stop now; it starts again at the next login (works over SSH)
launchctl bootout gui/$(id -u)/local.virtualscreen

# Stop and remove everything except the log (works over SSH)
./scripts/uninstall.sh

# List the supported resolutions
~/.local/bin/virtual-screen --list
```

If BetterDisplay also has a virtual screen, keep it disconnected while this is
installed, or the two compete for the main display:

```sh
BD=/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
$BD get -identifiers                     # find the virtual screen's tagID
$BD set -tagID=3 -connected=off          # replace 3 with that tagID
$BD set -tagID=3 -connected=on           # switch back
```

When the virtual display goes away, macOS falls back to its default headless
1920x1080 screen.

## What install.sh sets up

No `sudo`; everything lives in your own account. Running it again replaces the
current installation.

| Path | Purpose |
| --- | --- |
| `~/.local/bin/virtual-screen` | the binary |
| `~/Library/LaunchAgents/local.virtualscreen.plist` | starts it at login and restarts it if it crashes |
| `~/Library/Logs/virtual-screen.log` | log |

## Resolutions

Resolutions are in points. HiDPI renders at twice the pixels, which is what a
remote client like RustDesk receives:

| `--resolution` | HiDPI pixels | `--no-hidpi` pixels |
| --- | --- | --- |
| 1920x1080 | 3840x2160 | 1920x1080 |
| 2560x1440 (default) | 5120x2880 | 2560x1440 |
| 3200x1800 | 6400x3600 | 3200x1800 |
| 3840x2160 | 7680x4320 | 3840x2160 |

All of these modes, in both forms, can also be picked in System Settings >
Displays while it runs; the `--resolution` value is applied again on each
launch.

## Limits

- Before login (at the login window) no user process runs, so there is no
  virtual display. Enable automatic login for unattended use.
- `CGVirtualDisplay` is private API and may change in a future macOS release.

## Development

```sh
swift build
swift test
.build/debug/virtual-screen --help
```
