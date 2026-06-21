class AppConfig {
  static const appName = 'Bizoot';
  static const androidPackagePlaceholder = 'com.app.bizoot';
  static const iosBundlePlaceholder = 'com.app.bizoot';
  static const supportEmail = 'support@bizoot.com';
  static const privacyPolicyUrl = 'https://www.bizoot.app/privacy';
  static const termsOfServiceUrl = 'https://www.bizoot.app/terms';
  static const marketingSiteUrl = 'https://www.bizoot.app';

  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: 'test_tznkszwBXjFFjMFMJurIvYIlsdf',
  );
  static const revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: 'test_tznkszwBXjFFjMFMJurIvYIlsdf',
  );
  static const revenueCatPremiumEntitlement = String.fromEnvironment(
    'REVENUECAT_PREMIUM_ENTITLEMENT',
    defaultValue: 'premium',
  );

  static const enableDevTools = bool.fromEnvironment(
    'BIZOOT_DEV_TOOLS',
    defaultValue: false,
  );

  static bool get isFirebaseConfigured => true;
  static bool get isRevenueCatConfigured =>
      revenueCatIosApiKey.isNotEmpty && revenueCatAndroidApiKey.isNotEmpty;
}
