# Kitchen Prep Board — iOS v2.0.0

The canonical iOS application now lives in the shared Very Good CLI/Flutter repository:

- Repository: https://github.com/lrodeveloperr/kitcgen-prep-android
- Canonical branch: `main`
- Merged source commit: `d3dff709b2510c949c381bcc63f8210a783194a0`
- Flutter project: `flutter_app`
- iOS runner: `flutter_app/ios`
- Shared entry point: `flutter_app/lib/main.dart`

The SwiftUI package retained in this repository is a historical presentation prototype. It is not the release source and must not be used to produce App Store builds.

The canonical Flutter source contains the shared Kitchen workflow, responsive phone/tablet UI, offline persistence, timers and notifications, UMP/non-personalized ads, remove-ads purchase wiring, and ten languages across eleven locales.

iOS still requires a macOS/Xcode compile, signed archive and TestFlight upload before release.
