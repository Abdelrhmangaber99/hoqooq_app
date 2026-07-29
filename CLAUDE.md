# Hoqooq Mobile App — Working Memory

Flutter (iOS + Android) client for the Hoqooq Legal Practice Management SaaS. This file is the persistent memory for this project across sessions — keep it tight, update it at the end of every milestone.

**Source documents (in priority order when they conflict):**
1. `hoqooq-postman-import.json` — wins on endpoint paths, request/response shapes, auth mechanism.
2. `Hoqooq_BRD_v1.docx` — wins on BR-### business rules, RBAC matrix, data dictionary intent.
3. `hoqooq_mobile_spec.md` — architecture/screens/milestones guidance; overridden by the above two where they disagree.
4. **`API_CONTRACT.md`** (repo root) — the parsed, annotated version of the Postman collection. **All `dio` calls go through this contract. No ad-hoc endpoint strings in features.**

---

## ⚠️ Backend updated 2026-07-30 (same day as M1) — M1's User/Role/Permission code is stale

The user replaced `hoqooq-postman-import.json` with a new export mid-session, after M1 shipped. This was a **real backend change, not re-randomized examples** — full breaking-changes list at the top of `API_CONTRACT.md`. Highlights that affect code already written:

- **Every path now has an `/api` prefix** (`POST /api/auth/login`, not `POST /auth/login`). `ApiConfig.baseUrl` doesn't have this yet — nothing will resolve until it's added.
- **`GET /users/me` (and `/users`, `/users/{id}`) changed shape.** `firstName`/`lastName`/`isActive` are gone, replaced by `fullName`/`status`; `isSuperAdmin`/`mfaEnabled` added. `Role` dropped `name`/`displayNameEn`/`displayNameAr` for just `{id, code, scope}`; `Permission` dropped `resource`/`action` for just `{id, code}`. **`lib/features/authentication/domain/entities/user.dart`'s `fromJson` will throw on a real response right now** — all four removed fields are `required`. Not fixed yet; fix this before M2, since M2's Case model nests a full `primaryLawyer`/`team[].user` (both typed as `User`).
- Auth endpoints themselves (login/signup/refresh/logout/forgot-password/reset-password/change-password) are **byte-for-byte unchanged** apart from the prefix — nothing about M1's token/session/interceptor logic needs to change.
- Employees/reviews/consultations modules were removed entirely from the collection (resolves the reviews/consultations BR-violation flag from M1; employees module now has zero backing, a regression for BRD §6.2.3 Staff Management, not something to build around).
- Case and Client shapes were both completely rebuilt — see `API_CONTRACT.md` §8/§5. Any planning done against the old shapes (including the M2 `PLAN.md` draft written just before this update) is void and needs redoing against the new contract.

**Standing instruction from the user:** whenever the Postman collection changes again, stop before writing any code, re-read it in full, diff every endpoint against the current `API_CONTRACT.md` (not just skim for new/removed folders — field-level diffs matter, e.g. top-level key sets can look identical while nested shapes changed), and produce an explicit breaking-changes list before touching Dart. Don't assume a re-export is just cosmetic.

---

## ⚠️ Critical: spec/collection divergence — read before writing API code

The Postman collection does **not** describe the product the BRD and spec define. It reads like a generic multi-tenant legal-SaaS boilerplate: it has public self-signup (`POST /auth/signup` with `userType`/`firmName`), a public lawyer marketplace (`/public/lawyers`), client reviews (`/reviews`), consultation booking (`/consultations`), hard `DELETE` on cases/documents/invoices/payments/courts/users, and a `tenantId` field the client supplies directly in request bodies. Every one of those either contradicts a specific BR-### rule or something the BRD explicitly lists as out-of-scope. Full itemized list in `API_CONTRACT.md` → "Gap Analysis Summary."

There's also **no subscription/billing surface at all** in the collection — no plan, no status field, no `X-Subscription-Status` header anywhere. BR-010/012's read-only-mode mechanism (which the spec's whole `ReadOnlyGuard` is built around) has no data source to read from in this API. Same for MFA (BR-033/6.1.3 says mandatory for Firm Admin — no `/auth/mfa/verify` exists) and case timeline (BR-017 — no `GET /cases/{id}/timeline`).

**Decision (confirmed 2026-07-30): treat the collection as literal ground truth.** Build the `dio` client and repositories against exactly what's callable today. This does NOT mean wiring every endpoint blindly — still flag a BR conflict inline the moment a milestone would use it (e.g. don't wire a destructive UI action to `DELETE /cases/{id}` without asking first), but don't block work waiting for a backend fix.

## ⚠️ Pre-existing codebase — not a blank slate

This repo already contains a working UI-only prototype (see `PROJECT_SUMMARY.md`), built with a **different stack** than `hoqooq_mobile_spec.md` assumes:

| | Spec assumed | Actually in `pubspec.yaml` / `lib/` |
|---|---|---|
| State mgmt | Riverpod 2.x + codegen | **flutter_bloc 9.x + Equatable** |
| DI | (implicit via Riverpod) | **get_it + injectable** (codegen, `injection.config.dart`) |
| Local storage | `drift` (SQLite) | **Hive + hive_flutter** |
| Forms | `reactive_forms` or hooks | not yet decided |
| Models | `freezed` | `freezed` ✓ (matches) |
| Routing | `go_router` | `go_router` ✓ (matches) |
| HTTP | `dio` | `dio` ✓ (matches; as of M1, `dio_client.dart` uses `ApiConfig.baseUrl` + `AuthInterceptor` + `RefreshInterceptor`. `TenantInterceptor` has been removed — see M1 session log) |

Existing features (`lib/features/`: authentication, calendar, cases, clients, dashboard, notifications, profile) are wired to **mock repositories** (`mock_auth_repository.dart`, `mock_case_repository.dart`, etc.) returning fake data — no real network calls yet. **Decision (confirmed 2026-07-30): keep the existing stack.** flutter_bloc/get_it/Hive stay; the spec's Riverpod/drift recommendation is superseded. M1 adapts to this stack rather than migrating away from it.

---

## Non-negotiable rules (BR-###)

| ID | Rule | App must do |
|---|---|---|
| BR-003 | Tenant isolation, row-scoped | Never send `tenant_id`/`tenantId` from the client (backend derives it from the JWT). `TenantInterceptor`'s client-side header injection was removed in M1 for this reason — **still note the collection's `POST/PATCH /users` request bodies accept a client-supplied `tenantId` field; don't populate it from any future staff-management screen.** Cross-tenant fetch → 404 rendered as "Not found," never "Forbidden." |
| BR-005 | Firm Admin full CRUD, non-restrictable | Never hide a module from Firm Admin in UI gating. |
| BR-010 | Subscription lifecycle → read-only mode | On `SUSPENDED`/`PAST_DUE`, disable all create/update/delete UI with a banner. **No data source for this in the current API contract — flagged above.** |
| BR-016/BR-024/BR-028/BR-029 | No hard delete (cases, documents, financial records) | Never wire a destructive "delete" UI action straight to the collection's `DELETE` endpoints for these entities without confirming with the user first — those endpoints being present doesn't make using them correct. |
| BR-030 | Per-firm isolated RAG | AI chat renders only `sources[]` the backend returns; never merge/cache across tenants. |
| BR-032 | AI is advisory | Every AI output shows "AI-generated — verify before use"; human edits always win over AI output. |
| BR-033 | Auth | Access token short-lived, in memory only; refresh token in `flutter_secure_storage` only, never plain SharedPreferences/Hive. |
| BR-034 | RBAC enforced at backend | UI hides disallowed actions as UX only; always handle a 403 gracefully — never assume UI gating is sufficient. |
| BR-037 | Mobile/API parity | This app is a client of the same tenant-scoped API as web. No mobile-only shortcut endpoints. |

Full rule set: BRD §7 (BR-001 – BR-037). Ask before writing code that could violate one.

## Tech stack

**Confirmed:** Flutter + Dart 3, `flutter_bloc`, `get_it` + `injectable`, `go_router`, `dio`, `freezed` + `json_serializable`, `flutter_secure_storage`, `hive`/`hive_flutter`, `logger`, `connectivity_plus`, `mocktail` + `bloc_test` (test deps, added M1).

**Localization:** two systems now coexist, deliberately. Existing screens (dashboard, calendar, clients, etc.) use the original `assets/lang/*.json` + `context.tr()` extension. New auth-flow strings added in M1 use Flutter's official ARB pipeline (`lib/l10n/app_en.arb` / `app_ar.arb` → generated `GeneratedAppLocalizations`, imported as `gen_l10n.GeneratedAppLocalizations` in `main.dart` to avoid a name clash with the existing custom `AppLocalizations` class). Finishing the migration for non-auth screens is a later-milestone task, not done.

**Environments:** dev/local only for now; staging and prod base URLs don't exist yet. `--dart-define=API_BASE_URL=...` per spec §14, defaulting to the dev URL until staging/prod are stood up.

**Push notifications:** deferred to M6 per spec — no Firebase project wiring before then.

**Open items still needing your input before they block a later milestone:**
- Actual dev/local base URL value — `ApiConfig.baseUrl` (`lib/core/network/api_config.dart`) defaults to `http://localhost:3000` via `--dart-define=API_BASE_URL`; replace with your real value whenever available.
- iOS/Android minimum versions — defaulting to spec's iOS 14+ / Android 8 (API 26)+ until told otherwise.
- Package name / bundle ID — `pubspec.yaml` still has `name: hqooq`; Android is still `com.example.hqooq` (Flutter's default placeholder, never customized). Not touched — a build/deploy-milestone concern.
- Endpoints with no example response in the collection (`/roles`, `/roles/permissions`, `/ai/*`, `/calendar/timeline`, download endpoints) — treated as "real but undocumented"; build against best-guess shapes and revisit against a running environment when reached in a later milestone.
- **`User.isFirmAdmin` is hardcoded `false`** (`lib/features/authentication/domain/entities/user.dart`) — no example anywhere in `API_CONTRACT.md` shows a real `role.name` value for Firm Admin. Confirm the actual value against a live login response before any milestone that gates UI on Firm Admin status.
- `AuthResponse.user` (login/refresh) is typed `Map<String, dynamic>?`, not `User` — every worked example shows `"user": {}`. The app always re-fetches via `GET /users/me` instead of trusting this field; revisit if a real response ever shows a populated shape here.

## Folder structure (as it exists today)

```
lib/
  core/
    auth/               # user_role.dart (unused by auth now; still referenced nowhere outside itself)
    errors/             # failures.dart
    localization/       # app_localizations.dart (JSON-based), locale_bloc/event/state
    network/            # api_config.dart, dio_client.dart, interceptors/{auth,refresh}_interceptor.dart, api_result.dart
    router/             # app_router.dart, route_guards.dart
    storage/            # token_storage.dart (added M1)
    theme/              # app_colors/radius/spacing/typography, theme_bloc/event/state
    widgets/            # app_button.dart, app_text_field.dart
  di/                   # injection.dart, injection.config.dart (injectable codegen)
  l10n/                 # app_en.arb, app_ar.arb, generated app_localizations*.dart (added M1)
  features/
    authentication/
      data/
        models/         # login_request, refresh_request, forgot/reset/change_password_request, auth_response (added M1)
        repository/      # auth_repository.dart (real, added M1) — no mock left
      domain/
        entities/       # user, role, permission, tenant_ref (rebuilt M1 to match API_CONTRACT.md)
        repository/      # i_auth_repository.dart
        usecases/        # login_use_case.dart
      presentation/
        bloc/            # auth_bloc, auth_event, auth_state, session_cubit, session_state (session_cubit added M1)
        pages/           # login, splash (sign_up_page.dart kept but unrouted, see PLAN.md)
    calendar/            # still mock-backed, untouched since M1 is auth-only
    cases/               # still mock-backed
    clients/             # still mock-backed
    dashboard/
    notifications/
    profile/
  shared/
    presentation/pages/main_layout.dart
l10n.yaml               # gen-l10n config (added M1)
test/
  core/network/interceptors/refresh_interceptor_test.dart
  features/authentication/{data/repository, domain/entities, presentation/{bloc,pages}}/*_test.dart
```
Each feature: `data/repository` → `domain/{entities,repository,usecases}` → `presentation/bloc` + `presentation/pages`. Auth is now fully real; calendar/cases/clients remain mock-backed until their own milestone.

## Coding conventions

- All HTTP calls go through a single `dio` client configured per `API_CONTRACT.md` — no endpoint strings hardcoded inside feature repositories.
- Every user-facing string localized from day one. New strings go in ARB (`lib/l10n/`); existing screens' strings stay in `assets/lang/*.json` until their own migration milestone — don't mix the two within one new screen.
- Test every screen in EN LTR and AR RTL.
- API repository tests mock `dio` (via `mocktail`) and assert request shape matches `API_CONTRACT.md` exactly (method, path, body keys/casing).
- Freezed for all DTOs; camelCase JSON keys per the actual collection (not the snake_case the spec guessed).
- Commit in small, milestone-scoped chunks referencing the milestone + BR-### or endpoint touched.
- Widget tests: avoid `pumpAndSettle()` when the tree contains an indeterminate `CircularProgressIndicator` (never settles → timeout) or a `SnackBar` (its ~4s auto-dismiss timer gets fast-forwarded past, so the assertion finds nothing) — use a couple of fixed-duration `pump()` calls instead. If a widget test needs the real JSON-based `AppLocalizations` and lives in a file with multiple `testWidgets` blocks, preload it once in `setUpAll` and serve it via a `SynchronousFuture`-based delegate rather than letting each test await the real `rootBundle` load — that async gap doesn't reliably resolve past the first `pumpWidget` in one file (see `login_page_test.dart`).

## Session log

- **2026-07-30 (planning)** — Read spec, BRD, and Postman collection end-to-end. Produced `API_CONTRACT.md`. Discovered (a) the Postman collection conflicts with BRD business rules in multiple places (public signup, hard deletes, marketplace endpoints, missing subscription/MFA/timeline/versioning surfaces) and (b) an existing flutter_bloc/get_it/Hive UI-only prototype already lives in `lib/`, differing from the spec's Riverpod/drift assumption. Also found the git repository root is the entire home directory (`/Users/abdelrhmangaber`), not this project folder — flagged to user. User confirmed: (1) treat the Postman collection as literal ground truth, flag BR conflicts inline per-milestone rather than blocking; (2) keep the existing flutter_bloc/get_it/Hive stack, no migration to Riverpod/drift; (3) dev/local base URL only for now; (4) defer Firebase/FCM to M6 per spec. `PLAN.md` for M1 drafted and approved.

- **2026-07-30 (M1 execution)** — Before writing code: initialized a proper git repo scoped to this project folder (`git init` inside `hoqooq_app-main`, per user's choice — the home-directory-wide repo is untouched and not used for this project going forward), and got explicit answers on the plan's three flagged decisions: remove `TenantInterceptor` outright, remove the sign-up nav entry (keep the page file, unrouted), migrate to ARB for new auth strings now. Implemented M1 in full per `PLAN.md`'s checklist — see that file for the itemized breakdown. Highlights not obvious from a diff: `AuthResponse.user` is deliberately untyped (`Map<String, dynamic>?`) because every login/refresh example in the collection shows an empty `user: {}`, so the app always re-fetches via `GET /users/me` instead of trusting it; `User.isFirmAdmin` is a scaffolded `false` pending a real `role.name` example; `SessionCubit` (not `AuthBloc`'s own state) is the actual source of truth read by route guards and the Dio interceptors, since interceptors can't cleanly depend on a widget-scoped Bloc. 31 tests added, all green; `flutter analyze` clean; `dart format` clean on every file this milestone touched (pre-existing formatting debt elsewhere in the repo was left alone to keep the diff reviewable — flagged, not fixed). M2 not started.

- **2026-07-30 (M2 planning)** — User approved M1 and asked for an M2 plan only, no implementation. Confirmed M2 scope with the user: Cases + Clients only (read-only), not the spec's full M2 grouping — hearings/calendar/documents/tasks/dashboard don't exist as features yet (documents/tasks have no folder at all; the existing `calendar` feature's single `Appointment` model actually conflates two separate real endpoints, `/hearings` and `/calendar`). Found that `case_details_page.dart` and `client_profile_page.dart` are fully hardcoded `StatelessWidget`s with no id parameter and no bloc wiring at all — not "swap the mock repo" like M1's login page, this needs real parameterization + bloc wiring built from scratch. Drafted an M2 `PLAN.md` section against the Case/Client shapes known at the time — **this draft was immediately superseded, see next entry.**

- **2026-07-30 (backend re-sync, before M2 implementation)** — User replaced `hoqooq-postman-import.json` with a new export and asked for a full re-scan before any M2 code: re-read the updated collection end-to-end, diffed every one of the 87 endpoints (was 97) against the previous version, rewrote `API_CONTRACT.md` with a "Breaking changes" section at the top. No backend source code or Swagger/OpenAPI file exists anywhere on disk in this environment (checked `~/development` to depth 2) — re-sync was Postman-collection-only, as that's the only artifact available. Key findings: global `/api` path prefix added everywhere; `Cases` and `Clients` shapes completely rebuilt to match the BRD's actual data dictionary (agreed_fee/priority/opening-closing dates/primary_lawyer_id/case_type_id for cases; client_code/national_id/commercial_reg/multi-value contact arrays for clients) — meaning the M2 `PLAN.md` draft from the previous entry is void, not just stale; `User`/`Role`/`Permission` shapes also changed (fullName replaces firstName+lastName, status replaces isActive, roles now `{id,code,scope}` not `{id,name,displayNameEn,displayNameAr}`) — **this breaks M1's shipped `User.fromJson` today**, not yet fixed, since the user asked to list breaking changes before writing any code; employees/reviews/consultations modules removed entirely (resolves the reviews/consultations BR flag, but employees now has zero backing, a regression). Auth endpoints themselves confirmed byte-for-byte unchanged aside from the prefix. Full detail in `API_CONTRACT.md`'s breaking-changes section. No code changed this pass — awaiting user direction on whether to patch M1's `User` model first or fold it into a redone M2 plan.
