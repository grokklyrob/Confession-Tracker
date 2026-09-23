# Handoff — 22 September 2026

Give this file to the next engineer or agent. `SPEC.md` is the source of truth. Do not add features from section 16.

## Where the project is

The Confession Tracker iOS app is implemented and on GitHub. The default branch is named `master` (there is no `main`).

- Repo: https://github.com/grokklyrob/Confession-Tracker
- Local folder: `/Users/robertstevens/Projects/confession`
- Bundle ID: `com.robertstevens.confessiontracker`
- Home screen name: Confession
- App Store name in the spec: Confession Tracker

The owner opened the app tonight on an iPhone 18 Pro simulator (via the Device Hub app) and said it looked good. That was a visual look, not a test pass.

## What already happened

- Debug build for the iOS Simulator succeeded from the command line (`CODE_SIGNING_ALLOWED=NO`) after two fixes: `DEVELOPMENT_ASSET_PATHS` is quoted so `Preview Content` stays one path, and the two deletes in `ConfessionsListView` use `try` with `withAnimation`.
- Commit `08da2b4` pushed that app to `origin/master`.
- After that commit, Xcode itself rewrote three files while the project was open. Those rewrites are included in the handoff commit. Rebuild before trusting them.

Xcode's rewrite:

- `Info.plist` no longer holds the display name, export-compliance flag, or portrait lock. Those moved into build settings as `INFOPLIST_KEY_CFBundleDisplayName = Confession`, `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`, and `INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait`. Launch screen color `LaunchBackground` stayed in `Info.plist`.
- `project.pbxproj` `objectVersion` went from 77 to 70.
- `Localizable.xcstrings` was reformatted. The original keys and plural variations are still there. Xcode also inserted empty extracted keys such as `"%lld"` and `"%lld days"`. Do not treat those empty keys as copy. `SWIFT_EMIT_LOC_STRINGS = YES` on the app target caused the extraction.

## Machine

Owner's computer: M2 MacBook Air, 8 GB RAM, Xcode installed at `/Applications/Xcode.app`. `xcode-select` still points at Command Line Tools. Command-line builds must set:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

Available simulator seen tonight: iPhone 18 Pro (`DA6FEEEB-3398-4EF5-8C79-DCCCF63538F9`). Do not assume an iPhone 16 simulator exists on this Mac.

The SwiftUI canvas (the pane beside the code) fails on this machine. It spins, then shows "Failed to launch app" and `cannot add handler to 0 from 0` in the debug console. That is the preview process dying under memory pressure while the real simulator is already running. Ignore the canvas. Use Device Hub or the Simulator app to look at the app.

The owner was shown Xcode's "Perform Changes" dialog (recommended warnings, string-catalog symbol generation, asset-symbol extensions) and told to press Cancel. Leave those off. String-catalog symbol generation will fight the dotted localization keys.

## What is not done

1. Unit tests and UI tests have never been run. Run them and fix failures. Likely sore spots: string-catalog plural lookup, UI test selectors (date picker, swipe, confirmation dialogs), and `@Model` isolation under Swift 6.
2. CI does not run. `.github/workflows/ci.yml` triggers on `main`, and this repo's branch is `master`. The job uses `macos-15`, whose default Xcode is 16.4, and it selects `/Applications/Xcode.app` without switching to Xcode 26. The spec wants Xcode 26. Point the workflow at `macos-26` (default Xcode 26) and at branch `master`, and pick a simulator name that image actually has. The README test command still says iPhone 16; update it to match.
3. Release build with warnings-as-errors has not been run locally.
4. `Scripts/static-checks.sh` passed before the Xcode rewrite. Run it again after the rebuild.
5. Icon Composer check of `ConfessionTracker/Resources/AppIcon.icon` (default, dark, clear, tinted) has not been done. The icon is an original calendar-page SVG, not an SF Symbol.
6. Before TestFlight, still open: VoiceOver, Dynamic Type AX5, Increase Contrast, Reduce Motion, Full Keyboard Access (spec 13.4); 1,000-entry scroll (13.5); App Privacy Report with no network; screenshots and App Store Connect metadata (section 14); a hosted privacy-policy URL matching spec 10.5; a priest or catechist review of `Content.json` recorded in the README.

## How to build

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test \
  -project ConfessionTracker.xcodeproj \
  -scheme ConfessionTracker \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

Signing: automatic, no entitlements file. Simulator and CI use `CODE_SIGNING_ALLOWED=NO`. A device build needs the owner's team selected in Signing & Capabilities.

## Product rules the next person must keep

- iPhone only, iOS 17+, portrait, SwiftUI, Swift 6, default MainActor isolation, SwiftData local store only, no CloudKit, no network, no third-party packages, no `print`.
- Settings is a sheet from the Confessions gear, not a tab.
- Test hooks (`-uiTesting`, `-resetState`, `-seed`) compile only in Debug and Profile, never Release.
- Store URL: Application Support `/ConfessionTracker.store`, file protection complete. UI tests use `Library/Caches/UITestStore` and the `uitests` UserDefaults suite.
- Interval buckets must stay exact. See `IntervalFormatter` and spec 5.1.5. A 376-day span is 12 months. Never `.years(1)`.
- Do not quote the forbidden ICEL phrases listed in spec 11.2.

## Suggested order for tomorrow

1. Rebuild Debug and confirm the Xcode file rewrite still compiles.
2. Fix CI so a push to `master` actually builds with Xcode 26, then run the local test suite and fix what fails.
3. Walk the app in the simulator against the acceptance criteria in Appendix D. Skip the canvas.
4. Leave TestFlight paperwork (privacy URL, content review, screenshots, device accessibility audit) until the tests are green.
