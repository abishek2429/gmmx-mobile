class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080');
  static const tenantSlug =
      String.fromEnvironment('TENANT_SLUG', defaultValue: 'coachmohan');
  static const firebaseEmailLinkUrl = String.fromEnvironment(
    'FIREBASE_EMAIL_LINK_URL',
    defaultValue: 'https://gmmx.app/auth/email-link',
  );
  static const androidPackageName = String.fromEnvironment(
    'ANDROID_PACKAGE_NAME',
    defaultValue: 'com.example.gmmx_mobile',
  );
  static const iosBundleId = String.fromEnvironment(
    'IOS_BUNDLE_ID',
    defaultValue: 'com.example.gmmxMobile',
  );
}
