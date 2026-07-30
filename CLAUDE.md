# Hoqooq Mobile App — Working Memory

Flutter (iOS + Android) client for the Hoqooq Legal Practice Management SaaS. This file is the persistent memory for this project across sessions — keep it tight, update it at the end of every milestone.

**Source documents (in priority order when they conflict):**
1. **`Hoqooq-main/`** (gitignored, reference-only — the real NestJS backend source, given direct filesystem access 2026-07-30) — wins on everything: endpoint paths, request/response shapes, auth mechanism, error/envelope format, delete semantics. Supersedes the Postman collection wherever they disagree.
2. `hoqooq-postman-import.json` — secondary/illustrative now; still useful for example payloads, but not trusted over the source above.
3. `Hoqooq_BRD_v1.docx` — wins on BR-### business rules, RBAC matrix, data dictionary intent.
4. `hoqooq_mobile_spec.md` — architecture/screens/milestones guidance; overridden by the above where they disagree.
5. **`API_CONTRACT.md`** (repo root) — the parsed, annotated contract, now reconciled against the real backend source. **All `dio` calls go through this contract. No ad-hoc endpoint strings in features.**

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

Originally, every feature (`lib/features/`: authentication, calendar, cases, clients, dashboard, notifications, profile) was wired to **mock repositories** returning fake data. **Decision (confirmed 2026-07-30): keep the existing stack.** flutter_bloc/get_it/Hive stay; the spec's Riverpod/drift recommendation is superseded. As of M2, authentication/cases/clients are real; calendar/dashboard/notifications/profile remain mock-or-static.

---

## Non-negotiable rules (BR-###)

| ID | Rule | App must do |
|---|---|---|
| BR-003 | Tenant isolation, row-scoped | Never send `tenant_id`/`tenantId` from the client (backend derives it from the JWT). `TenantInterceptor`'s client-side header injection was removed in M1 for this reason — **still note the collection's `POST/PATCH /users` request bodies accept a client-supplied `tenantId` field; don't populate it from any future staff-management screen.** Cross-tenant fetch → 404 rendered as "Not found," never "Forbidden." |
| BR-005 | Firm Admin full CRUD, non-restrictable | Never hide a module from Firm Admin in UI gating. |
| BR-010 | Subscription lifecycle → read-only mode | On `SUSPENDED`/`PAST_DUE`, disable all create/update/delete UI with a banner. **No data source for this in the current API contract — flagged above.** |
| BR-016/BR-024/BR-028/BR-029 | No hard delete (cases, documents, financial records) | **Confirmed satisfied (2026-07-30, backend-source re-sync):** every `DELETE` endpoint is TypeORM soft-delete (`@DeleteDateColumn`/`isArchived` via `.softRemove()` — see `API_CONTRACT.md` finding C). Earlier versions of this file wrongly claimed hard delete, inferred from the Postman collection's lack of implementation visibility; that inference was wrong. Still use a confirmation dialog for destructive-looking UI actions as normal UX, but it is not a BR violation. |
| BR-026 | Case-fee visibility restricted to Firm Admin / `finance.read` | **Fixed 2026-07-30:** `agreedFee` on `LegalCase` is hidden unless `SessionCubit`'s authenticated user reports `isFirmAdmin`, now computed for real via `Tenant.ownerUserId == user.id` (see `API_CONTRACT.md` finding D) instead of a hardcoded `false`. Apply the same hide-by-default pattern (default `false` on any failure/ambiguity) to any other finance-gated field. |
| BR-030 | Per-firm isolated RAG | AI chat renders only `sources[]` the backend returns; never merge/cache across tenants. |
| BR-032 | AI is advisory | Every AI output shows "AI-generated — verify before use"; human edits always win over AI output. |
| BR-033 | Auth | Access token short-lived, in memory only; refresh token in `flutter_secure_storage` only, never plain SharedPreferences/Hive. |
| BR-034 | RBAC enforced at backend | UI hides disallowed actions as UX only; always handle a 403 gracefully — never assume UI gating is sufficient. |
| BR-037 | Mobile/API parity | This app is a client of the same tenant-scoped API as web. No mobile-only shortcut endpoints. |

Full rule set: BRD §7 (BR-001 – BR-037). Ask before writing code that could violate one.

## Tech stack

**Confirmed:** Flutter + Dart 3, `flutter_bloc`, `get_it` + `injectable`, `go_router`, `dio`, `freezed` + `json_serializable`, `flutter_secure_storage`, `hive`/`hive_flutter`, `logger`, `connectivity_plus`, `mocktail` + `bloc_test` (test deps, added M1).

**Localization:** two systems now coexist, deliberately. Existing screens (dashboard, calendar, clients, etc.) use the original `assets/lang/*.json` + `context.tr()` extension. New auth-flow strings added in M1 use Flutter's official ARB pipeline (`lib/l10n/app_en.arb` / `app_ar.arb` → generated `GeneratedAppLocalizations`, imported as `gen_l10n.GeneratedAppLocalizations` in `main.dart` to avoid a name clash with the existing custom `AppLocalizations` class). Finishing the migration for non-auth screens is a later-milestone task, not done.

**Environments:** dev/local only for now; staging and prod base URLs don't exist yet. `--dart-define=API_BASE_URL=...` per spec §14, defaulting to `http://localhost:3005` (confirmed 2026-07-30 from `Hoqooq-main/docker-compose.yml`'s `3005:3000` port mapping) until staging/prod are stood up. `/api` is appended by `ApiConfig` itself (`src/main.ts`'s global prefix), not part of the base URL.

**Push notifications:** deferred to M6 per spec — no Firebase project wiring before then.

**Open items still needing your input before they block a later milestone:**
- iOS/Android minimum versions — defaulting to spec's iOS 14+ / Android 8 (API 26)+ until told otherwise.
- Package name / bundle ID — `pubspec.yaml` still has `name: hqooq`; Android is still `com.example.hqooq` (Flutter's default placeholder, never customized). Not touched — a build/deploy-milestone concern.
- Endpoints with no example response in the collection (`/roles`, `/roles/permissions`, `/ai/*`, `/calendar/timeline`, download endpoints) — treated as "real but undocumented"; build against best-guess shapes and revisit against a running environment when reached in a later milestone.
- `AuthResponse.user` (login/refresh) is typed `Map<String, dynamic>?`, not `User` — every worked example shows `"user": {}`. The app always re-fetches via `GET /users/me` instead of trusting this field; revisit if a real response ever shows a populated shape here.

**Resolved 2026-07-30 (backend-source re-sync — see session log entry below and `API_CONTRACT.md`):**
- Base URL — confirmed `http://localhost:3005` from `docker-compose.yml`.
- `isFirmAdmin` — no longer a `User` property (was hardcoded `false`); computed in `AuthBloc._resolveIsFirmAdmin()` from `Tenant.ownerUserId == user.id` via a new `GET /tenants/my-firm` call, stored on `SessionAuthenticated.isFirmAdmin`.
- Response envelope (`{success, statusCode, message, data}`) and error shape (`{success:false, statusCode, message, error, timestamp}`) — previously invisible, now unwrapped/parsed by `EnvelopeInterceptor` and `mapDioError()` respectively.
- Delete semantics — confirmed soft-delete throughout, not hard delete (see BR table above).

## Folder structure (as it exists today)

```
lib/
  core/
    auth/               # user_role.dart (unused by auth now; still referenced nowhere outside itself)
    errors/             # failures.dart
    localization/       # app_localizations.dart (JSON-based), locale_bloc/event/state
    network/            # api_config.dart, dio_client.dart, dio_error_mapper.dart, interceptors/{auth,refresh,envelope}_interceptor.dart (envelope added in the backend-source fix pass), api_result.dart
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
        entities/       # user, role, permission, tenant_ref (rebuilt M1 to match API_CONTRACT.md), my_firm (added in the backend-source fix pass, backs isFirmAdmin derivation only)
        repository/      # i_auth_repository.dart
        usecases/        # login_use_case.dart
      presentation/
        bloc/            # auth_bloc, auth_event, auth_state, session_cubit, session_state (session_cubit added M1)
        pages/           # login, splash (sign_up_page.dart kept but unrouted, see PLAN.md)
    calendar/            # still mock-backed — not touched, out of M2 scope
    cases/
      data/repository/    # case_repository.dart (real, added M2) — no mock left
      domain/entities/    # legal_case, case_status, case_priority, case_type_lookup, court, case_team_member (added M2)
      presentation/
        bloc/            # cases_bloc/event/state, case_details_bloc/event/state (added M2)
        pages/           # cases_page.dart (added M2 — no list screen existed before), case_details_page.dart (rewritten M2)
        case_display_helpers.dart  # enum → label/color mapping (added M2)
    clients/
      data/repository/    # client_repository.dart (real, added M2) — no mock left
      domain/entities/    # client (rebuilt M2), client_status, client_type (added M2)
      presentation/
        bloc/            # clients_bloc/event/state, client_details_bloc/event/state (added M2)
        pages/           # clients_page.dart (updated M2), client_profile_page.dart (rewritten M2)
        client_display_helpers.dart  # (added M2)
    dashboard/            # still static UI, no data layer — out of M2 scope
    notifications/        # still static UI — out of M2 scope
    profile/              # still static UI — out of M2 scope
  shared/
    presentation/pages/main_layout.dart  # Cases tab added M2
    widgets/              # empty_state.dart, error_view.dart (added M2 — neither existed before)
l10n.yaml               # gen-l10n config (added M1)
test/
  core/network/interceptors/refresh_interceptor_test.dart
  features/authentication/{data/repository, domain/entities, presentation/{bloc,pages}}/*_test.dart
  features/cases/{data/repository, presentation/{bloc,pages}}/*_test.dart
  features/clients/{data/repository, presentation/bloc}/*_test.dart
```
Each feature: `data/repository` → `domain/{entities,repository,usecases}` → `presentation/bloc` + `presentation/pages`. Auth, Cases, and Clients are now fully real; calendar/dashboard/notifications/profile remain mock-or-static until their own milestone.

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

- **2026-07-30 (backend re-sync, before M2 implementation)** — User replaced `hoqooq-postman-import.json` with a new export and asked for a full re-scan before any M2 code: re-read the updated collection end-to-end, diffed every one of the 87 endpoints (was 97) against the previous version, rewrote `API_CONTRACT.md` with a "Breaking changes" section at the top. No backend source code or Swagger/OpenAPI file exists anywhere on disk in this environment (checked `~/development` to depth 2) — re-sync was Postman-collection-only, as that's the only artifact available. Key findings: global `/api` path prefix added everywhere; `Cases` and `Clients` shapes completely rebuilt to match the BRD's actual data dictionary (agreed_fee/priority/opening-closing dates/primary_lawyer_id/case_type_id for cases; client_code/national_id/commercial_reg/multi-value contact arrays for clients) — meaning the M2 `PLAN.md` draft from the previous entry is void, not just stale; `User`/`Role`/`Permission` shapes also changed (fullName replaces firstName+lastName, status replaces isActive, roles now `{id,code,scope}` not `{id,name,displayNameEn,displayNameAr}`) — this broke M1's shipped `User.fromJson`; employees/reviews/consultations modules removed entirely (resolves the reviews/consultations BR flag, but employees now has zero backing, a regression). Auth endpoints themselves confirmed byte-for-byte unchanged aside from the prefix. No code changed this pass — presented the breaking-changes list and asked the user how to proceed.

- **2026-07-30 (M1 patch + M2 redraft)** — User confirmed: patch M1's `User`/`Role`/`Permission` now as a standalone fix, and redraft the M2 plan. Patched: `ApiConfig.baseUrl` now appends `/api` (picked up automatically by both the main `Dio` and `RefreshInterceptor`'s internal raw `Dio`, since both read the same constant); `User`/`Role`/`Permission` rebuilt to the new shape (`fullName`/`status`/`isSuperAdmin`/`mfaEnabled` on `User`; `{id,code,scope}` on `Role`; `{id,code}` on `Permission`); `hasPerm()` signature changed from `(resource, action)` to a single `permissionCode` string. Updated the three M1 test files that built `User`/`Role`/`Permission` fixtures against the old shape — no test logic changed, only fixtures. 31 tests still green, analyzer clean. Redrafted `PLAN.md`'s M2 section (superseded draft kept above for history, not deleted) against the current `Case`/`Client` shapes: `agreedFee`/`priority`/`primaryLawyer`(`User`)/`caseType`/`defaultCourt`/`team[]` for Case, `clientCode`/`nationalId`/`commercialReg`/`emails[]`/`phones[]`/`addresses[]` for Client. Flagged that the new backend actually has **less** for Case Detail to show than the old mock assumed (notes/note-endpoint removed, no team-assignment endpoint), and a new BR-026 question (whether to show `agreedFee` to everyone given `isFirmAdmin` still can't be detected) that didn't exist in the superseded draft. Still just a plan — awaiting approval before M2 code.

- **2026-07-30 (M2 execution)** — User approved the redraft with one explicit instruction on decision #2: `agreedFee` hidden unless the user is positively identified as Firm Admin, never shown to everyone as a fallback (BR-026). Implemented M2 in full per `PLAN.md`'s checklist — see that file for the itemized breakdown. Highlights not obvious from a diff: discovered mid-implementation that no Cases list screen existed at all (`CasesBloc` was dead code referenced by nothing) — built `CasesPage` from scratch and added a Cases bottom-nav tab, since list+detail isn't reachable without one; extracted `mapDioError()` into a shared helper once a third repository needed the identical logic; `ClientDetailsBloc` fetches the full case list and filters by `clientId` client-side (no server-side filter/sub-resource exists), and degrades to an empty case list rather than failing the whole screen if that secondary fetch fails. Widget-test coverage is real but intentionally not exhaustive — one focused widget-test file for `CaseDetailsPage` locks in the `agreedFee` gating specifically (the security-sensitive behavior from this session's explicit instruction), not full EN/AR coverage for every M2 screen; flagged as a known gap, not silently called complete. 55 tests total (was 31), all green; `flutter analyze` clean; `dart format` clean on every file touched — reverted a `dart format lib/` run partway through this session after it swept in ~15 unrelated pre-existing files outside M2's scope (same discipline as M1: format only what you actually touched). 6 commits this milestone. M3 not started.

- **2026-07-30 (M2 retrospective)** — User asked for a review-only retrospective before M3 planning: architecture health, technical debt, duplicated code, pattern consistency across M1/M2, outstanding TODOs/ambiguities, and confirmation no mock implementations remained in Cases/Clients. No code changed. User approved the report with explicit decisions: don't extract generic list blocs/scaffolds yet (Rule of Three — revisit once a third list-based feature exists); keep repositories/display helpers unchanged; add widget smoke tests for `CasesPage`/`ClientsPage`/`ClientProfilePage` before M3 (still pending as of this entry); verify pagination/filtering against the live backend before adding more list modules rather than assuming client-side filtering is permanent (this was resolved definitively in the next entry below — it is permanent, confirmed from source); keep treating undocumented backend behavior as unknown, not guessed.

- **2026-07-30 (backend-source access + critical fix pass)** — User gave direct filesystem access to the real NestJS backend source (`Hoqooq-main/`, gitignored — reference-only, not part of this repo) and asked to review it and make the best decisions. This resolved several previously-open ambiguities and surfaced one previously-invisible, severity-critical bug:
  - **Response envelope (critical):** every backend response is wrapped `{success, statusCode, message, data}` (`src/core/interceptors/transform.interceptor.ts`) — every repository parsing `response.data` as the resource shape directly was broken against a real server since M1. Fixed with a new `EnvelopeInterceptor` unwrapping `data` before any repository sees it.
  - **Error shape (critical):** confirmed `{success:false, statusCode, message, error, timestamp}` (`src/core/filters/http-exception.filter.ts`) — `mapDioError()` now surfaces the real backend `message` in `Failure`s shown to the user, instead of only generic per-status strings.
  - **Soft delete confirmed, not hard delete:** `@DeleteDateColumn`/`isArchived` + `.softRemove()` throughout (`src/core/entities/base.entity.ts` and every service). This corrects a standing wrong claim in `API_CONTRACT.md` and this file's BR table — BR-016/024/028/029 were never actually violated; that was a wrong inference from the Postman collection's lack of implementation visibility.
  - **`isFirmAdmin` resolved for real:** no `firm_admin` role exists in seed data; the mechanism is `Tenant.ownerUserId == user.id` (`src/modules/tenants/entities/tenant.entity.ts`, seeds at `src/infrastructure/database/seeds/seed.ts`). Moved `isFirmAdmin` off `User` entirely (it was a hardcoded `false` getter) onto `SessionAuthenticated`, computed once per login/session-restore by a new `AuthBloc._resolveIsFirmAdmin()` calling a new `IAuthRepository.getMyFirm()` (`GET /tenants/my-firm`). Defaults to `false` on any failure — same secure-default direction as the original BR-026 instruction.
  - **`CaseStatus` completed:** added `SUSPENDED`/`CLOSED` (confirmed exhaustive from `src/modules/cases/entities/case.entity.ts`), previously only `DRAFT/ACTIVE/ARCHIVED` had ever been observed in Postman examples.
  - **Base URL confirmed:** `http://localhost:3005` (docker-compose host port), `/api` global prefix from `src/main.ts`.
  - **Pagination/filtering confirmed permanent:** `cases.controller.ts`/`clients.controller.ts` have zero `@Query()` params — client-side filtering (the app's existing implementation) is the real, permanent design, not a stopgap.
  - Updated `case_details_page_test.dart` (isFirmAdmin moved from a `User` getter to `SessionAuthenticated` field — also newly exercises the "shown to Firm Admin" branch for the first time, previously untestable since it was hardcoded false), `auth_bloc_test.dart` (two new blocTest cases for the `getMyFirm()` success/failure paths), `user_test.dart` (removed the now-obsolete `isFirmAdmin` getter test). 57 tests total (was 55), all green; `flutter analyze` clean. `Hoqooq-main/` added to `.gitignore` — it's reference material, not app code, and shouldn't live in this repo's git history. `API_CONTRACT.md` rewritten with the backend-source findings and corrected delete-semantics claims (see its top section). M3 planning and the still-pending M2-retrospective widget-smoke-test follow-up have not started.
