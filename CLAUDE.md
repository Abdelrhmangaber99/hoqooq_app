# Hoqooq Mobile App — Working Memory

Flutter (iOS + Android) client for the Hoqooq Legal Practice Management SaaS. This file is the persistent memory for this project across sessions — keep it tight, update it at the end of every milestone.

**Source documents (in priority order when they conflict):**
1. `hoqooq-postman-import.json` — wins on endpoint paths, request/response shapes, auth mechanism.
2. `Hoqooq_BRD_v1.docx` — wins on BR-### business rules, RBAC matrix, data dictionary intent.
3. `hoqooq_mobile_spec.md` — architecture/screens/milestones guidance; overridden by the above two where they disagree.
4. **`API_CONTRACT.md`** (repo root) — the parsed, annotated version of the Postman collection. **All `dio` calls go through this contract. No ad-hoc endpoint strings in features.**

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
| HTTP | `dio` | `dio` ✓ (matches, but `dio_client.dart` hardcodes `baseUrl: https://api.hoqooq.com/v1` and has no auth/refresh interceptor yet — only a `TenantInterceptor` stub that reads `tenantId` off the mock user and injects `X-Tenant-ID` header client-side, which is itself a BR-003 violation to keep in mind when this gets replaced) |

Existing features (`lib/features/`: authentication, calendar, cases, clients, dashboard, notifications, profile) are wired to **mock repositories** (`mock_auth_repository.dart`, `mock_case_repository.dart`, etc.) returning fake data — no real network calls yet. **Decision (confirmed 2026-07-30): keep the existing stack.** flutter_bloc/get_it/Hive stay; the spec's Riverpod/drift recommendation is superseded. M1 adapts to this stack rather than migrating away from it.

---

## Non-negotiable rules (BR-###)

| ID | Rule | App must do |
|---|---|---|
| BR-003 | Tenant isolation, row-scoped | Never send `tenant_id`/`tenantId` from the client (backend derives it from the JWT) — **currently violated by the collection's `POST/PATCH /users` body and by `TenantInterceptor`'s client-side header injection; do not replicate that pattern for new code**. Cross-tenant fetch → 404 rendered as "Not found," never "Forbidden." |
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

**Confirmed:** Flutter + Dart 3, `flutter_bloc`, `get_it` + `injectable`, `go_router`, `dio`, `freezed` + `json_serializable`, `flutter_secure_storage`, `hive`/`hive_flutter`, `logger`, `connectivity_plus`, `intl` + ARB-less JSON localization (currently `assets/lang/` — spec wants ARB files, needs reconciling — open item).

**Environments:** dev/local only for now; staging and prod base URLs don't exist yet. `--dart-define=API_BASE_URL=...` per spec §14, defaulting to the dev URL until staging/prod are stood up.

**Push notifications:** deferred to M6 per spec — no Firebase project wiring before then.

**Open items still needing your input before they block a milestone (not blocking M1 itself):**
- Actual dev/local base URL value (currently a placeholder in `dio_client.dart`: `https://api.hoqooq.com/v1` — fictional, needs replacing).
- iOS/Android minimum versions — defaulting to spec's iOS 14+ / Android 8 (API 26)+ until told otherwise.
- Package name / bundle ID — `pubspec.yaml` has `name: hqooq` (no second "o"); Android `applicationId`/iOS bundle ID not yet set per-flavor. Defaulting to leaving `hqooq` and using `com.hoqooq.app`-style IDs as a placeholder — confirm before M1's flavor setup step actually runs.
- Endpoints with no example response in the collection (`/roles`, `/roles/permissions`, `/ai/*`, `/calendar/timeline`, download endpoints) — treated as "real but undocumented"; build against best-guess shapes and revisit against a running environment when reached in a later milestone. Not needed for M1 (auth + `/me` only).

## Folder structure (as it exists today)

```
lib/
  core/
    auth/               # user_role.dart
    errors/             # failures.dart
    localization/       # app_localizations.dart, locale_bloc/event/state
    network/            # dio_client.dart, interceptors/tenant_interceptor.dart, api_result.dart
    router/             # app_router.dart, route_guards.dart
    theme/              # app_colors/radius/spacing/typography, theme_bloc/event/state
    widgets/            # app_button.dart, app_text_field.dart
  di/                   # injection.dart, injection.config.dart (injectable codegen)
  features/
    authentication/     # data/domain/presentation, mock_auth_repository
    calendar/
    cases/
    clients/
    dashboard/
    notifications/
    profile/
  shared/
    presentation/pages/main_layout.dart
```
Each feature: `data/repository` (mock today, real `dio` repos to come) → `domain/{entities,repository,usecases}` → `presentation/bloc` + `presentation/pages`.

## Coding conventions

- All HTTP calls go through a single `dio` client configured per `API_CONTRACT.md` — no endpoint strings hardcoded inside feature repositories.
- Every user-facing string localized from day one (spec wants ARB; current code uses `assets/lang/*.json` — reconcile before M1 sign-off, see clarifying questions).
- Test every screen in EN LTR and AR RTL.
- API repository tests mock `dio` and assert request shape matches `API_CONTRACT.md` exactly (method, path, body keys/casing).
- Freezed for all DTOs; camelCase JSON keys per the actual collection (not the snake_case the spec guessed).
- Commit in small, milestone-scoped chunks referencing the milestone + BR-### or endpoint touched.

## Session log

- **2026-07-30** — Read spec, BRD, and Postman collection end-to-end. Produced `API_CONTRACT.md`. Discovered (a) the Postman collection conflicts with BRD business rules in multiple places (public signup, hard deletes, marketplace endpoints, missing subscription/MFA/timeline/versioning surfaces) and (b) an existing flutter_bloc/get_it/Hive UI-only prototype already lives in `lib/`, differing from the spec's Riverpod/drift assumption. Also found the git repository root is the entire home directory (`/Users/abdelrhmangaber`), not this project folder — flagged to user, not yet resolved. User confirmed: (1) treat the Postman collection as literal ground truth, flag BR conflicts inline per-milestone rather than blocking; (2) keep the existing flutter_bloc/get_it/Hive stack, no migration to Riverpod/drift; (3) dev/local base URL only for now (actual value still TBD from user); (4) defer Firebase/FCM to M6 per spec. Base URL value, min OS versions, package/bundle ID, and undocumented-endpoint handling still open (defaults assumed, noted above) — user said "continue" rather than answering each, so `PLAN.md` for M1 was drafted with explicit placeholders flagged rather than waiting further. Still waiting for explicit approval before writing any code.
