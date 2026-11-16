# App Store submission checklist

State on 2026-11-16 (prepared overnight; nothing has been submitted for review):

- App record created through Xcode Organizer: **Virtual Screen – HiDPI Display**, Apple ID
  `6835454670`, bundle ID `io.github.jo9900.VirtualScreen`, SKU `io.github.jo9900.VirtualScreen`,
  primary language English (U.S.). The plain name "Virtual Screen" is taken by another developer.
- Build **1.0.0 (1)** uploaded at 22:32 JST. Apple's processing result arrives by email and in
  the build list; check it first (see "Known risk").
- Support URL and privacy policy are live in the public repo
  [jo9900/virtual-screen-support](https://github.com/jo9900/virtual-screen-support).

Everything below is done in App Store Connect after logging in. Text to paste is in
`AppStore/metadata/<language>.md`; screenshots are in `AppStore/screenshots/<language>/`.

## 1. Check the build

- Apps → Virtual Screen – HiDPI Display → TestFlight (or the build section of version 1.0).
- If the email says **ITMS-90338: Non-public API usage**, the build was rejected for the private
  API and none of the steps below will get it approved. Stop and decide how to proceed.

## 2. App Information

- Localizable information (English (U.S.)): Name, Subtitle from `en-US.md`.
- Add localizations **Japanese** and **Chinese (Simplified)**; fill Name and Subtitle from `ja.md`
  and `zh-Hans.md`.
- Category: **Utilities** (secondary optional, e.g. Productivity).
- Content Rights: does not contain, show, or access third-party content.
- Age Rating: answer every question "None"/"No" → 4+.

## 3. Pricing and Availability

- Price: base country or region **Japan**, **¥1,000**; let App Store Connect set the other
  territories' prices.
- Availability: all countries or regions. China mainland may require an ICP Filing Number; if you
  do not have one, deselect China mainland.
- Paid apps need the **Paid Applications agreement** active (Business → Agreements, Tax, and
  Banking).

## 4. App Privacy

- Privacy Policy URL: `https://github.com/jo9900/virtual-screen-support/blob/main/PRIVACY.md`
- Data collection: **No, we do not collect data from this app.** Then Publish.

## 5. macOS App → version 1.0 (for each of the three localizations)

- Screenshots: drag the three files from `AppStore/screenshots/en/`, `ja/`, `zh-Hans/`
  (2880 × 1800, no alpha). The English set is used where a localization has none.
- Promotional Text, Description, Keywords from the metadata file.
- Support URL: `https://github.com/jo9900/virtual-screen-support`
- Build: select **1.0.0 (1)**.
- Copyright: `2026 <your name>`.
- App Review Information: your contact details; sign-in not required; Notes from the
  "App Review notes" section of `en-US.md`.
- Version Release: manual or automatic, your choice.
- Save. **Submit for Review is yours to press.**

## Known risk

`CGVirtualDisplay` is a private CoreGraphics class, and macOS has no public API for virtual
displays. App Review Guideline 2.5.1 allows public APIs only, so a rejection is likely; the
binary references the class directly and the review notes say so. Nothing hides it.

## Before submitting, also consider

- The source repo `jo9900/virtual-screen` is public and still has the original CLI. The app code is
  committed locally only. Making the repo private before pushing keeps buyers from building it.
- Tested on macOS 27.2 with Apple silicon only. The minimum is macOS 14 and the build includes
  Intel; neither older macOS nor Intel has been tried.

## Releasing an update

Bump `CURRENT_PROJECT_VERSION` (and `MARKETING_VERSION` for a new version) in `project.yml`, then
run `scripts/release.sh upload`.
