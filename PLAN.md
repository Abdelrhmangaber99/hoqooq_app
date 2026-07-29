# Milestone 1 — Foundation

**Status: complete.** All checklist items done; three items (below) were consciously left open per an explicit user answer or a genuine unresolved ambiguity, not overlooked.

## Framing

Most of what spec §15's "M1 — Foundation" describes (project setup, theming, i18n scaffolding, routing, DI) **already existed** in `lib/` — it was built as a UI-only prototype on mock repositories. This milestone was "replace the mock auth path with the real API and establish the patterns everything else builds on," not "build from scratch." Scope was deliberately narrow: **auth + `/users/me` only**.

Confirmed decisions this milestone executed against (see `CLAUDE.md`): collection = ground truth, keep flutter_bloc/get_it/Hive, dev-only base URL, FCM deferred to M6, remove `TenantInterceptor`, remove the sign-up nav entry, migrate to ARB for new auth strings.

## Resolved open items

| Item | Resolution |
|---|---|
| Dev base URL value | Placeholder `http://localhost:3000` via `ApiConfig.baseUrl`, overridable with `--dart-define=API_BASE_URL`. **Still needs your real dev URL** — not a blocker, just replace the default whenever you have it. |
| iOS/Android min versions | Left as spec's iOS 14+ / Android 8 (API 26)+ default; no platform config touched this milestone. |
| Package name / bundle ID | Left `pubspec.yaml`'s `hqooq` / Android's `com.example.hqooq` as-is; genuinely a build/deploy concern (spec §14), not Foundation. |
| Undocumented-response endpoints (`/roles`, `/ai/*`, etc.) | Not touched — out of M1 scope (auth + `/me` only). |
| `TenantInterceptor` | **Removed.** You confirmed removing it outright rather than keeping it "for now." |
| `sign_up_page.dart` | **Nav entry removed** (route deleted from `app_router.dart`, footer link removed from `login_page.dart`); the page file itself is left in place, unreferenced, per your answer. `register()`/signup was also dropped from `IAuthRepository` entirely — nothing in the reachable app calls it, consistent with BR-001. |
| Localization (ARB vs JSON) | **ARB set up** (`l10n.yaml`, `lib/l10n/app_en.arb` / `app_ar.arb`, generated `GeneratedAppLocalizations`) and wired into `main.dart` alongside the existing JSON-based `context.tr()`. Scope was exactly what the plan said: ARB for *new* auth-flow strings (currently: session-expired/generic/network error messages) — existing screens' strings stay on the JSON system until a later milestone finishes the migration. |

## Checklist

### 1. Dio client & interceptors (`lib/core/network/`) — done
- [x] `ApiConfig.baseUrl` via `--dart-define=API_BASE_URL`, dev placeholder default.
- [x] `AuthInterceptor` attaches `Authorization: Bearer <accessToken>` from `SessionCubit`.
- [x] `RefreshInterceptor`: on 401, calls `POST /auth/refresh` via its own interceptor-free `Dio` (avoids recursion), rotates the stored refresh token, retries the original request once; coalesces concurrent 401s into a single refresh call; clears session on refresh failure.
- [x] `TenantInterceptor` removed (BR-003).
- [x] Error mapping in `AuthRepository._mapError`: HTTP-status/DioException-type only — no error-envelope shape is confirmed anywhere in `API_CONTRACT.md` (every documented error example has an empty body), so nothing more specific could be built without guessing.

### 2. Secure storage & session — done
- [x] `TokenStorage` (`flutter_secure_storage`) stores only `refreshToken`.
- [x] `SessionCubit` holds the in-memory `accessToken` + `SessionState` (unknown/authenticated/unauthenticated); this — not `AuthBloc`'s own state — is what route guards and interceptors read.
- [x] `AuthBloc` drives `SessionCubit` and separately tracks the transient login-attempt UI state (loading/error) that `login_page.dart` already consumed.

### 3. Freezed models — auth + `/me` (per `API_CONTRACT.md` §1–2) — done
- [x] `LoginRequest`, `RefreshRequest`, `ForgotPasswordRequest`, `ResetPasswordRequest`, `ChangePasswordRequest`.
- [x] `AuthResponse { accessToken, refreshToken, user }` — `user` typed as `Map<String, dynamic>?`, not a strict `User`, because every worked login/refresh example in the collection shows `"user": {}` (unconfirmed shape); the app never reads this field.
- [x] `User`, `Role`, `Permission`, `TenantRef` — replaced the old prototype's `fullName`/`role` enum/`lawFirmName` shape entirely (verified nothing outside the auth feature depended on it).

All camelCase per the actual collection.

### 4. Repository layer — done
- [x] `AuthRepository` (real, dio-backed) implements `login`, `refresh`, `logout`, `getCurrentUser`, `forgotPassword`, `resetPassword`, `changePassword`.
- [x] `MockAuthRepository` deleted.
- [x] Repository tests (`mocktail`-mocked `Dio`) assert exact method/path/body for every call against `API_CONTRACT.md`.

### 5. RBAC derivation — done, with a flagged limit
- [x] `User.hasPerm(resource, action)` flattens `roles[].permissions[]` — generic, since no `resource`/`action` values are enumerated anywhere in `API_CONTRACT.md`.
- [x] `User.isFirmAdmin` scaffolded as `false` with a `TODO(BR-005)` comment — **still unconfirmed** what a Firm Admin's `role.name` actually looks like in a live response. Not resolved because no example exists to resolve it against, not because it was skipped.

### 6. Routing / guards — done
- [x] `route_guards.dart` reads `getIt<SessionCubit>().state` synchronously instead of calling the (now-removed) mock repository.
- [x] `SplashPage` dispatches `SessionRestoreRequested` on load; navigates via a `BlocListener<AuthBloc, AuthState>` once the restore attempt resolves (stored refresh token → `/auth/refresh` → `/users/me`), rather than the old unconditional 3-second-then-login-always behavior.

### 7. Screens — done
- [x] `login_page.dart` wired to real `LoginRequested` → real login → real `/users/me`; 401/other failures surface via `AuthError` → existing SnackBar.
- [x] Sign-up nav entry removed (see resolved items above).
- [x] MFA / invite-activation screens: still not buildable — no `/auth/mfa/verify` or `/auth/activate` endpoint exists in the collection. Deferred until the backend gains them.

### 8. Localization — done (partial migration, by design)
- [x] ARB infra live; new auth-flow strings (`sessionExpired`, `genericErrorMessage`, `networkErrorMessage`) use it. Existing screens' strings remain on the JSON system — finishing that migration is explicitly out of M1's scope.

### 9. Tests — done
- [x] Unit: `RefreshInterceptor` (5 cases: pass-through, no-retry-loop, no-token, success-and-retry, failure-clears-session), `User.hasPerm`/`fullName`/`isFirmAdmin`.
- [x] Bloc: `AuthBloc` (7 cases across login/session-restore/logout, via `bloc_test`).
- [x] Widget: `login_page.dart` in EN/LTR and AR/RTL, plus loading and error states (via `MockBloc` + a preloaded-synchronous localization delegate — the real async JSON delegate proved flaky across multiple `testWidgets` blocks in one file; documented in the test file).
- [x] Repository: `dio`-mocked, asserting exact request shape against `API_CONTRACT.md` for every auth endpoint.
- 31 tests total, all green. `flutter analyze` clean on the whole project. `dart format` clean on every file touched this milestone (pre-existing files elsewhere in the repo have unrelated formatting debt from before this session — left untouched to keep this milestone's diff reviewable).

### Out of scope for M1 (explicitly deferred, not forgotten)
- MFA, invite-token activation, device/FCM registration — no backend endpoints exist yet.
- Subscription-status / read-only-mode wiring — no data source exists anywhere in the collection (see `API_CONTRACT.md` gap analysis); `ReadOnlyGuard` has nothing to read.
- Finishing the JSON→ARB migration for non-auth screens.

## Definition of done
- [x] Localization decision resolved (ARB for new auth strings).
- [x] `TenantInterceptor` decision resolved (removed).
- [x] Login → secure token storage → `GET /users/me` → session populated, **no mock repository left in the auth path**.
- [x] Refresh-on-401 covered by passing tests.
- [x] Freezed models for auth + `/me` match `API_CONTRACT.md`; `dio`-mock repository tests green.
- [x] `flutter analyze` clean; `dart format` clean on all M1-touched files.
- [x] `CLAUDE.md` updated (this pass) with what changed and what's still open.

---

## Next: Milestone 2 proposal — not started

Per your collaboration rule ("work milestone by milestone... do not skip ahead"), M2 is **not** started and no code for it exists yet. Before drafting an M2 checklist I'd want to confirm: which read-only screens to prioritize first (spec §15 groups dashboard, cases, clients, hearings, calendar, documents-list, tasks-list together — that's a lot for one milestone), and whether the existing mock repositories for calendar/cases/clients (still untouched, still mock-backed) should be replaced screen-by-screen or all at once. Will propose a scoped M2 `PLAN.md` when you're ready to continue.
