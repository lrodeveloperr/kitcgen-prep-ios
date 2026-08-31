# Kitchen Prep Board — iOS v2.0.0

The canonical iOS application now lives in the shared Very Good CLI/Flutter repository:

- Repository: https://github.com/lrodeveloperr/kitcgen-prep-android
- Canonical branch: `main`
- Current canonical commit: `44a3ba89b86a6ae963a664ea979be22dd66e9c32`
- Flutter project: `flutter_app`
- iOS runner: `flutter_app/ios`
- Shared entry point: `flutter_app/lib/main.dart`

The SwiftUI package retained in this repository is a historical presentation prototype. It is not the release source and must not be used to produce App Store builds.

The canonical Flutter source contains the shared Kitchen workflow, responsive phone/tablet UI, offline persistence, timers and notifications, UMP/non-personalized ads, remove-ads purchase wiring, and ten languages across eleven locales. The current `main` also includes the Kitchen controller save-safety/undo protections and salted, collision-aware timer notification IDs with regression coverage.

The last recorded Flutter analysis/test pass applies to the earlier validated canonical commit documented in `VERIFICATION.json`; the latest `main` changes have not yet had a fresh CI run. iOS still requires a macOS/Xcode compile, signed archive and TestFlight upload before release.
