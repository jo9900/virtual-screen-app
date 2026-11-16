# App Store listing — English (U.S.) (primary language)

## Name (30 max)

Virtual Screen – HiDPI Display

## Subtitle (30 max)

HiDPI screen for headless Macs

## Promotional Text (170 max)

Give a Mac without a monitor a sharp 1440p or 4K screen for remote desktop. Switch resolution and HiDPI right from the menu bar.

## Keywords (100 max, comma-separated, no spaces after commas)

virtual display,headless,remote desktop,HiDPI,4K,resolution,dummy display,monitor,screen sharing

## Description (4000 max)

Virtual Screen gives a Mac without a monitor a real high-resolution display.

When a Mac runs without a monitor, macOS usually gives it a fixed 1920 × 1080 screen, so remote desktop and screen sharing apps are stuck at that size. Virtual Screen adds a virtual display at the resolution you choose, makes it the main display, and keeps it there.

FEATURES
• Four 16:9 resolutions: 1920 × 1080, 2560 × 1440, 3200 × 1800 and 3840 × 2160
• HiDPI or 1x rendering, switchable at any time from the menu bar
• The virtual screen becomes the main display automatically
• Optional start at login, so the screen is ready after every restart
• Remembers your choice, and recreates the display if macOS removes it
• Picks up changes you make in System Settings > Displays
• Lives in the menu bar: no Dock icon, no drivers, nothing to configure

GOOD TO KNOW
• HiDPI renders at twice the pixels. A remote client receives the full pixel size, for example 5120 × 2880 for 2560 × 1440 HiDPI. Choose 1x if your connection is slow.
• The virtual display exists while Virtual Screen is running. At the login window, before any app runs, macOS shows its default screen; turn on automatic login for unattended Macs.
• Use one virtual display tool at a time, so they do not compete for the main display.

## What's New

(Not needed for version 1.0.)

## URLs

- Support URL: https://github.com/jo9900/virtual-screen-support
- Marketing URL: (leave empty)
- Privacy Policy URL: https://github.com/jo9900/virtual-screen-support/blob/main/PRIVACY.md

## App Review notes

Virtual Screen is a menu bar app with no Dock icon. After launch, a display icon appears in the
menu bar, and the app asks once whether to start at login.

How to test:
1. Launch the app. A virtual display named "Virtual Screen" is created and becomes the main
   display. The first menu item shows the current mode, e.g. "2560 × 1440 HiDPI · Main Display".
2. Choose another resolution or toggle HiDPI in the menu; the display switches immediately.
3. Uncheck "Enable Virtual Screen" to remove the virtual display, and check it again to restore it.
4. "Displays Settings…" opens System Settings > Displays, where the virtual display is listed.

The app is for Macs used without a monitor (for example through remote desktop), where macOS
otherwise provides only a fixed 1920 × 1080 screen. It creates the virtual display with the
CGVirtualDisplay class in CoreGraphics. It collects no data and makes no network connections.
