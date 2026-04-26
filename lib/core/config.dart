class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.gmmx.app');
  static const tenantSlug =
      String.fromEnvironment('TENANT_SLUG', defaultValue: 'coachmohan');
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
