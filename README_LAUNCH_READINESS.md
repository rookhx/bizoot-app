# Bizoot Launch Readiness

This document captures the current Android and iOS launch-prep status for Bizoot.

## Current identity

- Visible app name: `Bizoot`
- Android package target: `com.bizoot.app`
- iOS bundle identifier target: `com.bizoot.app`

## Billing status

- RevenueCat and store billing are intentionally not active in this build.
- The premium/paywall experience is UI-only for now.
- Before enabling billing later, re-add the purchase dependency and connect store products after Android and iOS metadata, signing, and review assets are stable.

## Safe config inputs

Only public configuration should live in the client build.

Required today:
- `FIREBASE_PROJECT_ID`

Optional platform services:
- `google-services.json` for Android Firebase
- `GoogleService-Info.plist` for iOS Firebase

Do not hardcode:
- service role keys
- private Firebase server keys
- future billing secrets

## Android readiness

Current status:
- `android/` exists
- app label is `Bizoot`
- package namespace is set to `com.bizoot.app`
- `MainActivity` package path has been aligned
- internet + notification permissions are declared
- Firebase messaging channel metadata is present

Declared permissions currently used:
- `android.permission.INTERNET`
- `android.permission.POST_NOTIFICATIONS`

Not added:
- app tracking permissions
- exact alarm permissions

## iOS readiness

Current status:
- `ios/` exists
- visible app name is `Bizoot`
- bundle identifier placeholders are set to `com.bizoot.app`

Not added:
- App Tracking Transparency
- billing entitlements

## Manual iOS steps still requiring Mac/Xcode

1. Open the project in Xcode from `ios/Runner.xcworkspace`.
2. Set the final Apple Team and signing certificates.
3. Confirm the final bundle identifier in Runner target settings.
4. Add `GoogleService-Info.plist` if Firebase push will be used on iOS.
5. Enable Push Notifications capability if cloud push is required for release.
6. Archive the app and validate signing/profile settings in Xcode.

## Remaining setup before billing

1. Finish Android signing config for release.
2. Finish iOS signing and provisioning.
3. Upload store listing assets and metadata.
4. Confirm notification flows on physical Android and iPhone devices.
5. Reintroduce billing only after store configuration is stable.
