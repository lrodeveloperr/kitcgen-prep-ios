# Kitchen Prep Board — iOS SwiftUI latest

`main` contains the current native SwiftUI source as an exploded Swift Package rather than only a ZIP artifact.

It uses the shared Kitchen Prep Board UI/workflow contract and targets iOS 16+.

## Backend boundary

The currently supplied authoritative backend contract is Android-specific (Room, Android broadcast/alarm recovery, Google Mobile Ads/UMP and Google Play Billing), SHA-256 `431414417d83201263951f0f3ed5854d38da88c7ec1b96c8e3d42168e556083b`.

Accordingly, this iOS source does **not** claim native backend parity that has not been implemented:

- no fabricated SwiftData/Core Data persistence layer;
- no fabricated iOS background timer/notification recovery behavior;
- no fabricated StoreKit remove-ads product;
- no fabricated iOS AdMob/consent implementation;
- no fabricated iOS share ingress.

The current `PreviewKitchenBackend` is intentionally a presentation/workflow adapter. The Android v1.1.1 critical/major fixes remain Android changes unless and until their native iOS equivalents are implemented and validated.

## Source

Open `Package.swift` in Xcode 16+ and use the included SwiftUI previews. Runtime content images are absent; workflow icons are native vector paths.

See `VERIFICATION.json` for the validation boundary.
