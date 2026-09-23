# Confession Tracker

A private, offline iPhone app for recording confessions and reading the traditional Act of Contrition and a step-by-step guide to the rite. Behaviour is defined by `SPEC.md`.

## Requirements

- Xcode 26 or later, with the iOS 26 SDK
- iOS 17.0 deployment target
- No package dependencies and no capabilities

## Open and run

1. Open `ConfessionTracker.xcodeproj`.
2. Select the ConfessionTracker scheme and an iPhone simulator.
3. For a device build, set your team under Signing & Capabilities. The target uses automatic signing and the bundle identifier `com.robertstevens.confessiontracker`. Simulator builds and CI do not need a team (`CODE_SIGNING_ALLOWED=NO`).

The Home Screen name is Confession. The App Store name in the spec is Confession Tracker.

## Tests

```sh
xcodebuild test \
  -project ConfessionTracker.xcodeproj \
  -scheme ConfessionTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

UI tests launch with `-uiTesting` and store data in `Library/Caches/UITestStore`, not the real log. `-resetState` clears that store. `-seed empty|three|thousand` loads fixtures after a reset. Those hooks are compiled only in Debug and the Profile configuration.

Source checks:

```sh
sh Scripts/static-checks.sh
```

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs unit tests, UI tests, a Release build, and the static checks on every pull request. Release treats warnings as errors.

Profile is a Release-optimisation configuration that also defines `TEST_HOOKS`, for Instruments runs with `-seed thousand`.

## Decisions

- Bundle identifier: `com.robertstevens.confessiontracker`, filling the spec's `com.<organisation>.confessiontracker`. Change `PRODUCT_BUNDLE_IDENTIFIER` if the organisation should be different. The logger subsystem uses the same identifier.
- The app icon is an original calendar-page glyph in `ConfessionTracker/Resources/AppIcon.icon`. It does not use an SF Symbol. Open it in Icon Composer and check default, dark, clear, and tinted appearances before submission.
- `.secondary` text can fall below WCAG AA in standard light mode. That is the system colour, and Increase Contrast raises it. Spec section 7.2 accepts this. Prayer text and guide lines stay `.primary`.
- A priest or catechist has not yet reviewed `Content.json` (spec 11.3). Record the reviewer and date here before release.
- The privacy policy URL required by App Store Connect is not hosted yet. It must match the in-app statement in spec section 10.5.

## Not done before TestFlight

These are device checks from the spec, not things the project can finish on its own:

- VoiceOver, Dynamic Type AX5, Increase Contrast, Reduce Motion, and Full Keyboard Access (section 13.4)
- Scroll and launch performance with 1,000 entries (section 13.5)
- App Privacy Report showing no network activity
- Screenshots and App Store Connect metadata (section 14)
