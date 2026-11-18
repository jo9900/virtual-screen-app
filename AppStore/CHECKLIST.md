# App Store submission checklist

App: **Virtual Screen – HiDPI Display** (Apple ID `6835454670`, bundle ID
`io.github.jo9900.VirtualScreen`, SKU `io.github.jo9900.VirtualScreen`, primary language English (U.S.)).
The plain name "Virtual Screen" is taken by another developer.

## Done in App Store Connect (2026-11-17)

- Build **1.0.0 (1)**: processed, status "Ready to Submit"; selected on version 1.0.0.
- App Information: names and subtitles for English (U.S.), Japanese, Chinese (Simplified)
  (Japanese and Chinese use localized names because the English name was rejected as "already
  used" in those localizations); category Utilities / Productivity; no third-party content;
  age rating 4+.
- Pricing: base country Japan, ¥1,000, prices for other territories set automatically.
- Availability: 174 countries or regions; **China mainland excluded** (needs an ICP filing, a
  security assessment report and an AIGC declaration).
- App Privacy: privacy policy URL in all three languages; "Data Not Collected" answered.
- Version 1.0.0, all three languages: promotional text, description, keywords, support URL,
  three screenshots each. Copyright `2026 jo9900` (shown as "© 2026 jo9900", same as ClipNest). Review notes from `metadata/en-US.md`.
- App Review Information: contact details copied from the owner's ClipNest listing; "Sign-in
  required" unchecked (the app has no account).
- Digital Services Act: non-trader for this app (owner's decision).
- Release option left at the default: release automatically after approval.

## Submitted

The owner published App Privacy and submitted version 1.0.0 for review on 2026-11-17; status
"Waiting for Review". It releases automatically once approved.

## Result

Rejected on 2026-11-18 by an automated binary scan under Guideline 2.5.1: the app references the
non-public classes `CGVirtualDisplay`, `CGVirtualDisplayDescriptor`, `CGVirtualDisplayMode` and
`CGVirtualDisplaySettings`. macOS has no public API for virtual displays, so the app is distributed
as a notarized DMG on GitHub Releases instead (see `CLAUDE.md`, "Releasing"). This file and the
rest of `AppStore/` are kept for reference.

## Known risk

`CGVirtualDisplay` is a private CoreGraphics class, and macOS has no public API for virtual
displays. App Review Guideline 2.5.1 allows public APIs only, so a rejection is possible. The build
passed Apple's automated processing; the review notes state the class openly. Nothing hides it.

## Also consider

- Tested on macOS 27.2 with Apple silicon only. The minimum is macOS 14 and the build includes
  Intel; neither older macOS nor Intel has been tried.
