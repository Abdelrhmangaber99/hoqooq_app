/// Host for all API calls, overridable at build/run time via
/// `--dart-define=API_BASE_URL=...` per spec §14 (dev/staging/prod
/// flavors). Defaults to `http://localhost:3005` per the backend's
/// `docker-compose.yml` (`api` service maps host `3005` -> container
/// `3000`) — confirmed from the actual backend source
/// (`Hoqooq-main/docker-compose.yml`), not a guess. If you run the
/// backend bare (`npm run start:dev`) instead of via `docker compose up`,
/// override with `--dart-define=API_BASE_URL=http://localhost:3000`.
class ApiConfig {
  ApiConfig._();

  static const String _host = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3005',
  );

  /// Confirmed via `app.setGlobalPrefix('api', ...)` in the backend's
  /// `src/main.ts` — baked in here so call sites keep using bare paths
  /// like `/auth/login`.
  static const String baseUrl = '$_host/api';
}
