/// Host for all API calls, overridable at build/run time via
/// `--dart-define=API_BASE_URL=...` per spec §14 (dev/staging/prod
/// flavors). Defaults to a local dev placeholder — the collection's own
/// `baseUrl` variable is just `"/"`, so there is no real URL to default to
/// yet (see CLAUDE.md open items). Replace this default once a real
/// dev/staging/prod URL is confirmed.
class ApiConfig {
  ApiConfig._();

  static const String _host = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Every endpoint in API_CONTRACT.md is documented under an `/api`
  /// prefix (added in a 2026-07-30 backend update) — baked in here so
  /// call sites keep using bare paths like `/auth/login`.
  static const String baseUrl = '$_host/api';
}
