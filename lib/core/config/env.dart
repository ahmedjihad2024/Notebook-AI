/// Build-time backend selection. The default is the deployed API; pass
/// `--dart-define=BASE_URL=...` to point a build elsewhere:
///
/// - Local backend (iOS sim):  --dart-define=BASE_URL=http://127.0.0.1:8000/api/v1
/// - Local (Android emulator): --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1
///
/// NOTE: the mobile API ships with the backend `development` branch — the
/// server must be deployed from it for this default to work.
class Env {
  Env._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://4u-api.mawaeidk.com/api/v1',
  );

}
