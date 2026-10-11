/// Host for all API calls, overridable at build/run time via
/// `--dart-define=API_BASE_URL=...` per spec §14 (dev/staging/prod
/// flavors). Default confirmed from the backend's `docker-compose.yml`
/// (`api` service maps host `3006` -> container `3006` — changed
/// 2026-08-06 from the earlier `3005:3000`, alongside backend
/// health-endpoint/startup fixes; re-check this file if login ever starts
/// timing out again after a backend re-sync).
///
/// **The host here is a LAN IP, not `localhost` — deliberate, for
/// physical-device testing.** `localhost` resolves to the device itself,
/// not the dev machine, on a real iPhone/Android phone. If this stops
/// matching the dev machine's actual IP (e.g. after a Wi-Fi reconnect),
/// requests hang for `dio_client.dart`'s full 30s `connectTimeout` and
/// surface as a generic "No internet connection" — re-check with
/// `ipconfig getifaddr en0` (macOS) before assuming a backend/code
/// regression. If you run the backend bare (`npm run start:dev`) instead
/// of via `docker compose up`, override with
/// `--dart-define=API_BASE_URL=http://localhost:3000` (bare `npm run
/// start:dev` still defaults to port 3000, unlike the Docker Compose
/// setup, which now uses 3006 — check `Hoqooq-main/.env`/`.env.example`
/// if this ever needs re-confirming).
class ApiConfig {
  ApiConfig._();

  static const String _host = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.50.240.246:3006',
  );

  /// Confirmed via `app.setGlobalPrefix('api', ...)` in the backend's
  /// `src/main.ts` — baked in here so call sites keep using bare paths
  /// like `/auth/login`.
  static const String baseUrl = '$_host/api';

  /// Host URL without the `/api` prefix (e.g. `http://13.50.240.246:3006`).
  static String get host => _host;
}
