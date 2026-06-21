# Flutter Subscription Control App Setup

This folder contains a Flutter version of the subscription-control app, built to mirror the current Expo + React Native product while keeping mock-safe fallbacks when backend keys are not configured.

## What is implemented

- Splash screen
- Premium onboarding flow
- Login / signup screen
- Dashboard with:
  - monthly total
  - yearly total
  - safe-to-spend
  - potential savings
  - subscription health score
  - money insights
- Add subscription / recurring payment screen
- Payment detail / edit screen
- Calendar screen
- Weekly report screen
- Settings screen
- Paywall screen
- Trial tracking
- Cancellation assistant
- Price history tracking structure
- Quick add presets
- Notification preference structure
- RevenueCat architecture
- Firebase-backed services with local fallback mode

## Folder structure

```text
flutter_subscription_app/
|- pubspec.yaml
|- analysis_options.yaml
|- README_FLUTTER_SETUP.md
`- lib/
   |- main.dart
   |- models/
   |- screens/
   |- services/
   |- theme/
   |- utils/
   `- widgets/
```

## Important limitation from this workspace

Flutter is not installed in the current coding environment, so I could not run:

- `flutter create`
- `flutter pub get`
- `flutter run`

That means the Dart app source is built, but native platform wrapper folders such as `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/` were not generated here.

## How to make it fully runnable in Android Studio / VS Code

1. Install Flutter locally on your machine and verify:

```bash
flutter doctor
```

2. Open a terminal inside:

```bash
cd flutter_subscription_app
```

3. Generate the standard Flutter platform folders in place:

```bash
flutter create .
```

This keeps the `lib/` code that was created and adds the missing native project wrappers.

4. Install packages:

```bash
flutter pub get
```

5. Run the app:

```bash
flutter run
```

## Required configuration values

Pass these with `--dart-define` in development, or wire them into your IDE run config:

```bash
--dart-define=FIREBASE_PROJECT_ID=your-firebase-project-id
--dart-define=REVENUECAT_APPLE_API_KEY=YOUR_APPLE_API_KEY
--dart-define=REVENUECAT_GOOGLE_API_KEY=YOUR_GOOGLE_API_KEY
--dart-define=REVENUECAT_ENTITLEMENT_ID=premium
```

Example:

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=your-firebase-project-id \
  --dart-define=REVENUECAT_APPLE_API_KEY=your-apple-key \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=your-google-key \
  --dart-define=REVENUECAT_ENTITLEMENT_ID=premium
```

## Firebase connection

The app uses Firebase services for auth, database, storage, and messaging.

Current services are ready for:

- auth
- user settings
- recurring payments CRUD
- price history writes

If Firebase is not fully configured for a target environment, the app falls back to local cached data where supported.

## RevenueCat connection

The app uses `purchases_flutter`.

Current subscription service supports:

- configure by platform API key
- read entitlement
- purchase current offering
- restore purchases
- fallback premium mode when RevenueCat keys are missing

## Notes on notifications

The app uses `flutter_local_notifications`.

The notification service currently includes structure for:

- pre-charge alerts
- trial-ending alerts
- weekly summary alerts

On a real device you will still need:

- Android notification permissions/channel setup
- iOS notification capabilities in Xcode

## Suggested next step

After running `flutter create .` and `flutter pub get`, open the project in Android Studio or VS Code and do one cleanup pass for:

- platform-specific notification configuration
- app icons / launcher assets
- RevenueCat entitlement/package wiring
- Firebase collection verification
