/// Base URL for all API calls. Overridable at build/run time via
/// `--dart-define=API_BASE_URL=...` per spec §14 (dev/staging/prod
/// flavors). Defaults to a local dev placeholder — the collection's own
/// `baseUrl` variable is just `"/"`, so there is no real URL to default to
/// yet (see CLAUDE.md open items). Replace this default once a real
/// dev/staging/prod URL is confirmed.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
