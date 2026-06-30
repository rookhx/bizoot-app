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
  static const googleGmailClientId = String.fromEnvironment(
    'GOOGLE_GMAIL_CLIENT_ID',
    defaultValue:
        '311435914370-hnrnv3kt2rib7cqnfa69boiug9pf3idm.apps.googleusercontent.com',
  );
  static const googleGmailServerClientId = String.fromEnvironment(
    'GOOGLE_GMAIL_SERVER_CLIENT_ID',
    defaultValue:
        '311435914370-sus3rod7ecbomkvgbusbbmlie15smg4r.apps.googleusercontent.com',
  );
  static const googleGmailIosReversedClientId = String.fromEnvironment(
    'GOOGLE_GMAIL_IOS_REVERSED_CLIENT_ID',
  );
  static const microsoftOutlookClientId = String.fromEnvironment(
    'MICROSOFT_OUTLOOK_CLIENT_ID',
    defaultValue: '53664665-2561-48c2-8403-fd6c2daa1c6e',
  );
  static const microsoftOutlookTenantId = String.fromEnvironment(
    'MICROSOFT_OUTLOOK_TENANT_ID',
    defaultValue: 'common',
  );
  static const microsoftOutlookRedirectUri = String.fromEnvironment(
    'MICROSOFT_OUTLOOK_REDIRECT_URI',
    defaultValue: 'com.app.bizoot://oauth/outlook',
  );
  static const revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: '',
  );
  static const revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: 'goog_KzlRDsgQhXgeTzwTulJFdkyhAFM',
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
  static bool get isGoogleGmailOAuthConfigured =>
      googleGmailClientId.isNotEmpty || googleGmailServerClientId.isNotEmpty;
  static bool get isMicrosoftOutlookOAuthConfigured =>
      microsoftOutlookClientId.isNotEmpty &&
      microsoftOutlookRedirectUri.isNotEmpty;
  static bool get isRevenueCatConfigured =>
      revenueCatIosApiKey.isNotEmpty || revenueCatAndroidApiKey.isNotEmpty;
}
