class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.gmmx.app');
  static const tenantSlug =
      String.fromEnvironment('TENANT_SLUG', defaultValue: 'coachmohan');
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '569266698773-uo2106moohqafqn6o5of5a150nqocpl3.apps.googleusercontent.com',
  );
  static const googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
}
