# Milestone 1 — Foundation

**Status: proposed, awaiting your approval. No code changes have been made yet.**

## Framing

Most of what spec §15's "M1 — Foundation" describes (project setup, theming, i18n scaffolding, routing, DI) **already exists** in `lib/` — it was built as a UI-only prototype on mock repositories. This milestone is therefore "replace the mock auth path with the real API and establish the patterns everything else builds on," not "build from scratch." Scope is deliberately narrow: **auth + `/users/me` only**, per your instruction.

Everything here builds on the confirmed decisions in `CLAUDE.md`: collection = ground truth, keep flutter_bloc/get_it/Hive, dev-only base URL, FCM deferred to M6.

## Still-open items that affect this milestone

These don't block starting M1, but do block specific steps — flagging exactly where:

| Item | Default I'll use unless you say otherwise | Blocks |
|---|---|---|
| Dev base URL value | Placeholder `http://localhost:3000`, overridable via `--dart-define=API_BASE_URL` | Step 1 — replace with your real value whenever you have it, doesn't block writing the interceptor |
| iOS/Android min versions | iOS 14+ / Android 8 (API 26)+ per spec | Nothing in M1 (no platform config touched this milestone) |
| Package name / bundle ID | Leave `pubspec.yaml`'s `hqooq` as-is, no Android/iOS flavor changes | Nothing in M1 — genuinely a build/deploy concern (spec §14), not Foundation |
| Undocumented-response endpoints (`/roles`, `/ai/*`, etc.) | Not touched in M1 (auth + `/me` only) | N/A for this milestone |

## Checklist

### 1. Dio client & interceptors (`lib/core/network/`)
- [ ] Replace hardcoded `baseUrl: 'https://api.hoqooq.com/v1'` in `dio_client.dart` with `--dart-define=API_BASE_URL`, defaulting to dev placeholder above.
- [ ] Add an auth interceptor: attaches `Authorization: Bearer <accessToken>` from in-memory session state to every request.
- [ ] Add a refresh interceptor: on `401`, call `POST /auth/refresh` with the stored `refreshToken`, retry the original request once, rotate the stored refresh token on success; on refresh failure, force logout and clear session.
- [ ] **Decision needed, not silently fixed:** `TenantInterceptor` currently reads `tenantId` off the mock user and injects it as `X-Tenant-ID`/`X-Workspace-Context` headers — this is exactly the client-side tenant assertion BR-003 forbids ("the app never sends a tenant_id from the client — the backend derives it"). Recommend removing it entirely once the real `/auth/login` response is confirmed to not need it. Will not delete without your go-ahead since a dev backend might currently depend on it.
- [ ] Error mapping in `core/errors/failures.dart`: the collection shows no worked example of an error response body anywhere (all error responses in the 97 examples have `body: null`) — so error-code-to-message mapping can only be scaffolded generically (HTTP status → generic message) until we see a real error payload from a running environment.

### 2. Secure storage & session
- [ ] `flutter_secure_storage` wrapper storing only `refreshToken`.
- [ ] `accessToken` held in memory only (session state), never persisted to Hive or secure storage.
- [ ] Extend `AuthBloc`/introduce a `SessionCubit` holding: current `User`, auth status (unknown/authenticated/unauthenticated), and exposing logout.

### 3. Freezed models — auth + `/me` only (per `API_CONTRACT.md` §1–2)
- [ ] `LoginRequest { email, password }` / `AuthResponse { accessToken, refreshToken, user }` (shared by login, signup, refresh)
- [ ] `RefreshRequest { refreshToken }`
- [ ] `ForgotPasswordRequest { email }`, `ResetPasswordRequest { token, newPassword }`, `ChangePasswordRequest { oldPassword, newPassword }`
- [ ] `User { id, email, firstName, lastName, isActive, createdAt, updatedAt, phone?, avatarUrl?, lastLoginAt?, roles: List<Role>, tenant: TenantRef }`
- [ ] `Role { id, name, displayNameEn, displayNameAr, permissions: List<Permission> }`
- [ ] `Permission { id, resource, action, displayNameEn, displayNameAr }`
- [ ] `TenantRef { id, name }`

All camelCase per the actual collection (not the spec's snake_case guess). `json_serializable`, generated via existing `build_runner` setup.

### 4. Repository layer
- [ ] Replace `mock_auth_repository.dart` with a real implementation of `IAuthRepository` calling: `login`, `refresh`, `logout`, `forgotPassword`, `resetPassword`, `changePassword`, `getCurrentUser` (`GET /users/me`).
- [ ] Repository tests mocking `Dio` (e.g. `DioAdapter`/interceptor-based test double), asserting exact method + path + body keys against `API_CONTRACT.md` for each call.

### 5. RBAC derivation
- [ ] `/users/me` has no flat `permissions: string[]` — permissions live nested under `roles[].permissions[]`. Implement `hasPerm(resource, action)` by flattening across all of the user's roles, replacing the spec's flat-array assumption.
- [ ] Firm-Admin detection needs a real role name to check against — no example in the collection shows an actual `role.name` value (e.g. is it `FIRM_ADMIN`, `firm_admin`, something else?). Scaffold the check but flag it as needing confirmation against a live login response.

### 6. Routing / guards
- [ ] Wire `route_guards.dart` redirects to real `SessionCubit` state instead of the mock.
- [ ] Splash screen attempts silent session restore (stored refresh token → `/auth/refresh` → `/users/me`) before routing to login or dashboard.

### 7. Screens
- [ ] Wire existing `login_page.dart` to the real login call; surface `401` inline.
- [ ] **Decision needed:** `sign_up_page.dart` already exists and calls a signup flow — but BR-001 says v1 has no public signup (invite-only). Recommend hiding/removing the sign-up entry point from navigation even though `POST /auth/signup` technically exists in the collection, since the mobile app is firm-users-only per the spec. Not deleting the page without your confirmation.
- [ ] MFA OTP screen (spec §5.1) and invite-activation screen (spec §4.2) are **not buildable this milestone** — no `/auth/mfa/verify` or `/auth/activate` endpoint exists in the collection. Deferred until the backend gains them.

### 8. Localization
- [ ] Open decision: current code uses `assets/lang/*.json`; spec wants ARB files. Recommend settling this now since M1's auth screens are the first real strings — either migrate to ARB in this milestone (sets the precedent for M2+) or confirm JSON is intentional and update `CLAUDE.md`/spec expectations accordingly.

### 9. Tests
- [ ] Unit: refresh-interceptor logic, `hasPerm()` derivation, session state transitions.
- [ ] Widget: login screen in EN LTR and AR RTL — empty/loading/error states.
- [ ] Repository: `dio` mock assertions matching `API_CONTRACT.md` request shapes exactly.

### Out of scope for M1 (explicitly deferred, not forgotten)
- MFA, invite-token activation, device/FCM registration — no backend endpoints exist yet.
- Subscription-status / read-only-mode wiring — no data source exists anywhere in the collection (see `API_CONTRACT.md` gap analysis); `ReadOnlyGuard` has nothing to read.
- Sign-up flow — left dormant per BR-001 pending your confirmation above.

## Definition of done
- [ ] Localization decision (ARB vs JSON) resolved and documented in `CLAUDE.md`.
- [ ] `TenantInterceptor` decision resolved (removed or justified).
- [ ] Login → secure token storage → `GET /users/me` → session populated, with **no mock repository left in the auth path**.
- [ ] Refresh-on-401 covered by a passing test.
- [ ] Freezed models for auth + `/me` match `API_CONTRACT.md` exactly; `dio`-mock repository tests green.
- [ ] `flutter analyze` + `dart format --set-exit-if-changed` clean.
- [ ] `CLAUDE.md` and `API_CONTRACT.md` updated with anything this milestone changed or learned (e.g. real role-name values once seen).

---

Waiting for your go-ahead (or edits to the checklist above) before touching any code.
