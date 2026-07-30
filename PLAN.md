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

# Milestone 2 — Cases & Clients (read-only)

**Status: SUPERSEDED — the Case/Client shapes this draft was written against no longer exist.** The user updated `hoqooq-postman-import.json` immediately after this was drafted; the backend rebuilt both `Case` and `Client` entirely (see `API_CONTRACT.md`'s breaking-changes section and `CLAUDE.md`'s session log). Left in place below for historical context — do not build against it. A redone version needs `agreedFee`/`priority`/`primaryLawyer`/`caseType`/`defaultCourt`/`team[]` for Case and `clientCode`/`nationalId`/`commercialReg`/`emails[]`/`phones[]`/`addresses[]` for Client instead of everything described here. Awaiting user direction before redrafting.

## Framing (original draft, now stale)

Spec §15's "M2 — Read-only workspace" groups dashboard, cases, clients, hearings, calendar, documents-list, and tasks-list into one milestone. That's too much for the same reason M1 stayed narrow: **tasks and documents don't exist as features at all yet** (no folder, no entity, no repository — not "mock-backed," genuinely unbuilt), and a real hearings feature doesn't exist either — the current `calendar` feature's single `Appointment` model conflates what are actually two separate real endpoints (`/hearings` for case-bound court sessions, `/calendar` for generic events). Bundling all of that into one milestone would repeat the mistake M1 was designed to avoid.

**You confirmed: M2 = Cases + Clients only, read-only (list + detail).** Hearings, calendar, documents, tasks, and dashboard move to M3+.

This is a bigger lift than it sounds, for a reason not obvious from the outside: **the existing `case_details_page.dart` and `client_profile_page.dart` are entirely hardcoded `StatelessWidget`s with no constructor parameters at all** — not wired to any bloc, not even accepting an `id` from navigation (`app_router.dart`'s routes for both don't pass one). This isn't "swap the repository under an existing wired screen" like M1's login page was; it's building the parameterization, the bloc wiring, and the data binding from scratch on top of screens that today are pure mockup.

## What's real vs. what the mock UI assumes

| | Mock entity/screen assumes | Actual `GET /cases` / `GET /clients` (`API_CONTRACT.md` §6, §10) |
|---|---|---|
| Case | `attorneyName` (string), `hearingsCount`, `documentsCount`, `daysOpen` — all flat display fields, none returned by the API | `id, title, caseNumber, status, type, clientId, filingDate, createdAt, updatedAt, client{...}, courtId, court{...}, description, assignments[]{id, role: LEAD\|SUPPORT, employee{...}}, notes[]{id, content, createdAt}` |
| Client | `area` (practice area), `info` (freeform "2 cases · Since 2024" string) — not API fields | `id, type: INDIVIDUAL\|COMPANY, name, email?, phone?, address?, taxId?, createdAt, updatedAt` |
| Case Detail tabs | Timeline, Hearings, Documents, Notes (all populated with hardcoded fake data) | Only **Notes** has any backing (`notes[]` comes inline with the case; `POST /cases/{id}/notes` exists). **No case-timeline endpoint exists at all** (confirmed gap in `API_CONTRACT.md`); Hearings/Documents tabs have no feature to back them yet in this milestone. |
| Client Detail | Hardcoded "Active Cases" list (2 fake case cards) + "Recent Appointments" section | No `GET /clients/{id}/cases` endpoint and no documented `?clientId=` filter on `GET /cases` — associating a client's cases means fetching the **full** case list and filtering client-side, or deferring the section. "Recent Appointments" has zero backing (calendar/hearings out of scope). |
| List endpoints | Spec assumed `?status=&lawyer_id=&q=&page=&limit=` on `GET /cases`, similar for clients | **No query parameters are documented on either `GET /cases` or `GET /clients`** in the collection — every example is a bare `GET` with an empty query array. Can't confirm server-side filtering/search/pagination exists at all. |

## Decisions needed before/while building (flagging now, not guessing)

1. **Case Detail tabs**: Timeline (no endpoint, ever, right now) and Hearings/Documents (no feature yet) can't show real data this milestone. Options: (a) remove those tabs entirely for M2, leaving Overview/Team/Notes; (b) keep them visible with a "Coming in a later milestone" placeholder. I'd default to (a) — a tab with a permanent placeholder reads as broken, not "not yet" — but flagging since it's a UI-scope call, not just an API one.
2. **Client Detail's case list**: fetch all cases and filter client-side by `clientId` (extra full-list round-trip, doesn't scale, but shows real data), or drop the section for M2 and revisit once/if a server-side filter or sub-resource turns up. Same question for "Recent Appointments" — I'd default to dropping it entirely (zero backing, not even a partial one) unless you want a "coming soon" placeholder instead.
3. **Pagination/search**: since no query params are documented, M2's lists would fetch the full `GET /cases` / `GET /clients` result and do search/filter/sort **client-side** in Dart, not server-side. Fine for a dev/small dataset; explicitly flagging that this won't scale and should be revisited once real query-param support is confirmed against a running backend.
4. **Case status/type enum completeness**: examples show case `status` values `OPEN`, `CLOSED`, `ARCHIVED` and `type` values `FAMILY`, `CIVIL`, `COMMERCIAL`, `LABOR` — these are only what appeared in the collection's randomly-generated examples, not a documented exhaustive enum list (no OpenAPI schema backs this collection). I'll model them as Dart enums with an `unknown` fallback case so an unseen value from a real server doesn't crash parsing, rather than assuming the four/three values I've seen are the complete set.

## Checklist

### 1. Freezed models — Case & Client (per `API_CONTRACT.md` §6, §10)
- [ ] `Client { id, type: ClientType, name, email?, phone?, address?, taxId?, createdAt, updatedAt }`
- [ ] `Case { id, title, caseNumber, status: CaseStatus, type: CaseType, clientId, filingDate?, createdAt, updatedAt, client: Client?, courtId?, court: Court?, description?, assignments: List<CaseAssignment>, notes: List<CaseNote> }`
- [ ] `Court { id, name, type, location?, contactInfo? }` (nested-only for M2 — no standalone courts feature/list screen this milestone)
- [ ] `CaseAssignment { id, role: AssignmentRole (LEAD|SUPPORT), employee: Employee }`
- [ ] `Employee { id, userId, position, hireDate, department, user: { id, email, firstName, lastName } }` (nested-only, matching what `assignments[].employee` returns — no standalone employee/staff feature this milestone)
- [ ] `CaseNote { id, content, createdAt }`
- [ ] `CaseStatus`/`CaseType`/`ClientType`/`AssignmentRole` enums with an `unknown` fallback for `json_serializable`'s `unknownEnumValue`, since the collection doesn't guarantee these lists are exhaustive.

### 2. Repositories
- [ ] `CaseRepository` (replaces `MockCaseRepository`): `getCases()` → `GET /cases`, `getCaseDetails(id)` → `GET /cases/{id}`. Read-only for M2 — no create/update/assignment/note-adding yet (that's a write milestone, M3+, per spec's own M2/M3 split).
- [ ] `ClientRepository` (replaces `MockClientRepository`): `getClients()` → `GET /clients`, `getClientDetails(id)` → `GET /clients/{id}`.
- [ ] Repository tests (`mocktail`-mocked `Dio`) asserting exact method/path against `API_CONTRACT.md`, same pattern as M1's `auth_repository_test.dart`.

### 3. Presentation
- [ ] `CasesBloc`/`ClientsBloc`: replace mock-backed list fetch with real repository calls; add loading/error/empty states (spec requires `EmptyState`/`ErrorView`/skeleton loader on every screen — none of that exists on the current mock-backed pages either, so this is also new work, not a regression).
- [ ] New `CaseDetailsBloc`/`ClientDetailsBloc` (don't currently exist) to fetch by id.
- [ ] `case_details_page.dart` and `client_profile_page.dart` **rewritten** to accept an id/entity from routing and render real bloc state, replacing 100% of the current hardcoded strings/numbers. Route definitions in `app_router.dart` updated to actually pass the id (`/case-details/:id`, `clients/:id/profile` or similar — exact path shape to match during implementation, not decided here).
- [ ] Case Detail: Overview (title, caseNumber, status, type, filingDate, description, client, court) + Team (assignments → employee name/position) + Notes (`notes[]`, read-only display — no "add note" UI yet, since that's a write action out of M2's read-only scope). Timeline/Hearings/Documents tabs: per decision #1 above.
- [ ] Client Detail: contact info (email/phone/address), type. Cases/appointments sections: per decision #2 above.
- [ ] List screens: search/filter done client-side per decision #3, with `EmptyState` for zero results and `ErrorView` with retry on failure (spec §5, not currently implemented on the mock screens either).

### 4. Localization
- [ ] Any new strings this milestone introduces go in ARB (`lib/l10n/`), per the M1 precedent — existing screen strings that get reused as-is stay wherever they already are.

### 5. Tests
- [ ] Repository tests for `CaseRepository`/`ClientRepository` (dio-mocked, exact request shape).
- [ ] Bloc tests for list + detail blocs (loading/success/error/empty).
- [ ] Widget tests for list and detail screens in EN/LTR and AR/RTL, following the M1 test file's pattern for avoiding the `pumpAndSettle`-vs-indeterminate-animation and localization-preload gotchas already documented in `CLAUDE.md`.

### Out of scope for M2 (explicitly deferred, not forgotten)
- Hearings, calendar, documents, tasks, dashboard — separate features, none exist yet, moved to M3+.
- Any write action (create/edit case or client, add note, change status, assign team member) — M2 is read-only per spec's own M2/M3 split.
- Case timeline — no endpoint exists in the collection at all (not a scoping choice, a hard gap).
- Server-side search/filter/pagination — not documented as existing; client-side only for now.

## Definition of done
- [ ] `Case`/`Client` (+ nested `Court`/`CaseAssignment`/`Employee`/`CaseNote`) models match `API_CONTRACT.md` exactly, with fallback-safe enums.
- [ ] `MockCaseRepository`/`MockClientRepository` deleted — no mock left in either path.
- [ ] Case Detail and Client Detail screens take a real id from routing and render real data — no hardcoded content remains.
- [ ] Decisions #1-#3 above resolved (by your review of this plan, or by your answer if you want something different from the stated defaults).
- [ ] All new/changed screens tested in EN/LTR and AR/RTL; empty/loading/error states covered.
- [ ] `flutter analyze` clean; `dart format` clean on every file this milestone touches.
- [ ] `CLAUDE.md` and `PLAN.md` updated with outcomes, same as M1.

---

Waiting for your review — either approve as-is (including the stated defaults for decisions #1-#3), or tell me what to change before I start.

---

# Milestone 2 — Cases & Clients (read-only), redraft v2

**Status: complete.** Approved with one explicit change to decision #2 below (agreedFee: hide by default, never show to everyone as a fallback). Same scope as the superseded draft above (Cases + Clients, read-only list + detail) — written against the Case/Client shapes confirmed in the current `API_CONTRACT.md` (post backend update). The framing/reasoning for why M2 stays narrow (documents/tasks don't exist as features, hearings/calendar aren't a real feature split from the mock `Appointment` model, `case_details_page.dart`/`client_profile_page.dart` are fully hardcoded with no id parameter) is unchanged from the superseded draft above and not repeated here.

**Discovered during implementation, not known when this was drafted:** there was no Cases list screen at all — `CasesBloc` existed but was dead code, referenced by no page, no route, no bottom-nav entry. Built `CasesPage` from scratch (mirroring `ClientsPage`'s existing pattern) and added a Cases tab to the bottom nav, since "Cases list + detail" isn't reachable without one. Noted, not silently absorbed into the checklist below.

## What's real now (per `API_CONTRACT.md` §5, §8)

| | Current `GET /cases` / `GET /cases/{id}` | Current `GET /clients` / `GET /clients/{id}` |
|---|---|---|
| Shape | `id, tenantId, caseNumber, status, clientId, caseTypeId, priority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: {id,name}, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: [{id, role, user: User}]` | `id, tenantId, clientCode, type, fullName, status, createdAt, updatedAt, nationalId?, commercialReg?, emails: string[], phones: string[], addresses: string[]` |
| `status` values seen | `DRAFT`, `ACTIVE`, `ARCHIVED` | `ACTIVE`, `ARCHIVED`, `INACTIVE` |
| `priority` values seen (Case only) | `NORMAL`, `HIGH`, `URGENT` (`LOW` not observed but plausible) | — |
| `type` values seen (Client only) | — | `INDIVIDUAL`, `COMPANY` |

None of these are documented as exhaustive (no OpenAPI schema backs this collection, only randomly-generated Postman examples) — same caveat as the superseded draft's decision #4, carried forward.

**Notable regressions from the superseded draft's assumptions, not improvements:** the previous Case shape had `notes[]` and a `POST /cases/{id}/notes` endpoint; both are **gone** in the current backend. There's also no more `POST /cases/{id}/assignments` — `team[]` exists on the Case response, but nothing in this collection shows how a team member ever gets added to it. For a read-only milestone this doesn't block anything (M2 never writes), but it means Case Detail now has **less** to show than previously planned: no Notes tab is possible at all, not because of an M2 scoping choice but because the endpoint doesn't exist anymore.

**Improvements:** `primaryLawyer` and `team[].user` are both full `User` objects — the exact same entity M1 just fixed (`fullName`/`status`/`roles[].code`/etc.). Case Detail's "Team" section reuses that entity directly rather than needing a separate lightweight user-reference type.

## Decisions — resolved

1. **Case Detail composition**: **Overview** (caseNumber, status, priority, caseType, court, openingDate/closingDate, outcomeSummary, agreedFee) + **Team** (`primaryLawyer` + `team[]`, each member's `role` + `user`). No Notes/Timeline/Hearings/Documents tabs — confirmed as approved, no tabs beyond these two.
2. **`agreedFee` visibility — user's explicit instruction, overriding my stated preference's phrasing but matching its direction**: hidden unless the authenticated user is positively identified as Firm Admin. Never shown to everyone as a fallback. Implemented as `showAgreedFee = sessionState is SessionAuthenticated && sessionState.user.isFirmAdmin` in `case_details_page.dart` — since `isFirmAdmin` is still hardcoded `false` (no confirmed `role.code` value), the field is hidden for every user today. Locked in with a widget test (`case_details_page_test.dart`) asserting it's hidden both with no session and with an authenticated non-admin session.
3. **Client's `emails[]`/`phones[]`/`addresses[]`**: shown as full joined lists, no primary assumed. Confirmed as approved.
4. **Client Detail's case list**: `ClientDetailsBloc` fetches the full case list and filters client-side by `clientId`. Confirmed as approved. If that secondary fetch fails, the client still shows with an empty case list rather than failing the whole screen (added during implementation, not explicitly in the original decision text, but consistent with its intent).
5. **Pagination/search**: client-side status-filter chips + search box on both list screens, mirroring `ClientsPage`'s pre-existing pattern. Confirmed as approved.
6. **Enum safety**: `CaseStatus`/`CasePriority`/`ClientStatus`/`ClientType` all have an `unknown` fallback via `json_serializable`'s `unknownEnumValue`. Confirmed as approved and tested (`case_repository_test.dart`/`client_repository_test.dart` both assert an unrecognized value parses to `unknown` instead of throwing).

## Checklist

### 1. Freezed models (per `API_CONTRACT.md` §5, §8) — done
- [x] `Client { id, tenantId, clientCode, type: ClientType, fullName, status: ClientStatus, createdAt, updatedAt, nationalId?, commercialReg?, emails: List<String>, phones: List<String>, addresses: List<String> }`
- [x] `LegalCase { id, tenantId, caseNumber, status: CaseStatus, clientId, caseTypeId, priority: CasePriority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: CaseTypeLookup, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: List<CaseTeamMember> }` (named `LegalCase`, not `Case` — `case` is a Dart reserved word)
- [x] `CaseTypeLookup { id, name }`, `Court { id, name, type, city?, address?, isActive, createdAt, updatedAt }`, `CaseTeamMember { id, role: String, user: User }` (reuses the auth feature's `User` directly)
- [x] `CaseStatus`/`CasePriority`/`ClientStatus`/`ClientType` enums with `unknown` fallback.

### 2. Repositories — done
- [x] `CaseRepository` (replaces `MockCaseRepository`): `getCases()` → `GET /cases`, `getCaseDetails(id)` → `GET /cases/{id}`.
- [x] `ClientRepository` (replaces `MockClientRepository`): `getClients()` → `GET /clients`, `getClientDetails(id)` → `GET /clients/{id}`.
- [x] Extracted `mapDioError()` (`lib/core/network/dio_error_mapper.dart`) out of `AuthRepository` into a shared helper, since `CaseRepository`/`ClientRepository` needed the identical logic — three copies would've been worse than one shared function.
- [x] Repository tests (`mocktail`-mocked `Dio`), same pattern as `auth_repository_test.dart`, plus unknown-enum-value fallback coverage.

### 3. Presentation — done
- [x] `CasesBloc`/`ClientsBloc`: real repository calls; fetch once, filter/search client-side (decision #5). `EmptyState`/`ErrorView` (new shared widgets — neither existed anywhere in the codebase before this milestone).
- [x] New `CaseDetailsBloc`/`ClientDetailsBloc`, calling the repository directly (no dedicated use case for a single pass-through call, same precedent as `AuthBloc.getCurrentUser()` in M1).
- [x] `case_details_page.dart`/`client_profile_page.dart` rewritten to accept a real id from routing (both were fully hardcoded with zero parameters before). `app_router.dart`: `/cases`, `/cases/:id`, `/clients/:id` (was a static `/clients/profile` with no id at all).
- [x] **New this milestone, not in the original checklist**: `CasesPage` built from scratch (no list screen existed — see note above), plus a Cases bottom-nav tab.
- [x] Case Detail: Overview + Team, `agreedFee` gated per decision #2.
- [x] Client Detail: header, contact arrays per decision #3, case list per decision #4.
- [x] List screens: client-side search/filter per decision #5.

### 4. Localization — done
- [x] New strings went to the JSON system (`assets/lang/*.json`), not ARB — these are non-auth screens, consistent with the boundary M1 established (ARB is for new *auth-flow* strings only).

### 5. Tests — done
- [x] Repository tests (dio-mocked, exact request shape + unknown-enum fallback).
- [x] Bloc tests for all four blocs (list fetch/filter/search, detail fetch, `ClientDetailsBloc`'s cases-fetch-fails fallback).
- [x] Widget test for `CaseDetailsPage` specifically covering the `agreedFee` gating (the security-sensitive behavior), using a `getIt`-registered `MockBloc`/`MockCubit` pair and the `SynchronousFuture`-preloaded localization delegate pattern from M1. Did not do full LTR/RTL widget-test duplication for every M2 screen (`CasesPage`/`ClientsPage` list screens, `ClientProfilePage`) — time-boxed to the highest-value test given this milestone's size; flagging as a coverage gap rather than silently calling it done.
- 55 tests total (was 31), all green. `flutter analyze` clean. `dart format` clean on every file touched this milestone.

### Out of scope for M2 (unchanged from the superseded draft)
- Hearings, calendar, documents, tasks, dashboard.
- Any write action.
- Case timeline, case notes (notes capability didn't just stay missing — it was actively removed this update).
- Server-side search/filter/pagination.

## Definition of done
- [x] `LegalCase`/`Client` (+ nested `CaseTypeLookup`/`Court`/`CaseTeamMember`) models match `API_CONTRACT.md` exactly, fallback-safe enums.
- [x] `MockCaseRepository`/`MockClientRepository` deleted.
- [x] Case Detail and Client Detail take a real id from routing, render real data.
- [x] Decisions #1-#6 resolved.
- [~] Screens tested — widget coverage is real but not exhaustive across every screen/locale combination (see Tests section above); empty/loading/error states are covered in the blocs and in the one widget test file, not screen-by-screen.
- [x] `flutter analyze` clean; `dart format` clean on every file touched.
- [x] `CLAUDE.md`/`PLAN.md` updated with outcomes (this pass).

**Post-ship regression fix (2026-07-30, during M3 pre-planning):** `CasesController` never enforces `CaseResponseDto` (no `plainToInstance`/`ClassSerializerInterceptor` applied) — the real wire shape is governed by `CasesService`'s TypeORM `relations: ['client', 'defaultCourt', 'team', 'opponents', 'timelineEvents']`, which does **not** include `caseType` or `primaryLawyer`, and only loads `'team'`, not `'team.user'`. `LegalCase.caseType`/`.primaryLawyer` and `CaseTeamMember.user` were wrongly `required`, and `CaseTeamMember.role` didn't match the real field name (`roleOnCase`) — all would throw against a real server. Fixed: all made nullable/renamed, UI degrades gracefully, dedicated widget test added. See `API_CONTRACT.md` §8 and `CLAUDE.md`'s session log for the full writeup. This is why M3 planning explicitly re-verified source before trusting any documented-but-unenforced response shape for the next five modules.

---

# Milestone 3 — Read-only workspace: Hearings, Documents, Tasks, Dashboard, Calendar

**Status: complete.** All checklist items done. Approved with two pre-implementation additions (M2 smoke-test debt closure, already done; backend re-verification, which caught and fixed a real M2 regression — see the session log) — see `CLAUDE.md` for the full close-out.

## Framing

Spec §15's "M2 — Read-only workspace" originally expected dashboard/cases/clients/hearings/calendar/documents/tasks all in one milestone. This project's actual M2 was scoped down to Cases + Clients only (per the M2-approval decision). M3, per your explicit direction, finishes what the spec's M2 described: **Hearings, Documents, Tasks, Dashboard, Calendar — all read-only.** Writes (create/edit case, schedule hearing, upload document, create task, etc.) move to M4, per spec's original M3 scope.

Every contract claim below is source-verified against `Hoqooq-main/` (see `API_CONTRACT.md` finding I), not inferred from the Postman collection — that collection is stale for these five modules relative to source (e.g. it's missing `HearingStatus.CANCELLED`, `hearings/documents/tasks` real vs. dead-file enum divergences, and the `/calendar/timeline` endpoint's real shape).

## Decisions — resolved (your answers, this session)

1. **Dashboard endpoint**: `GET /reports/dashboard` only (`{totalActiveCases, pendingTasks, upcomingHearings}`), correctly user-scoped. **Not** `GET /dashboard` — confirmed by the user: that endpoint is the platform-wide view for the System/Super Admin who runs the whole system, not a per-tenant metric, and isn't meant for this mobile client at all (this app only ever serves tenant-scoped actors, BR-037). Dashboard screen for M3 is therefore 3 metrics, no `recentActivity`, no invoice counts — those live on the Super-Admin-only endpoint, out of scope for this app entirely, not a gap to fill later.
2. **Hearings/Documents navigation**: sections inside `CaseDetailsPage` only, filtered client-side by `caseId` (fetch the full `/hearings`/`/documents` collection, filter locally — same pattern as `ClientDetailsBloc` filtering cases by `clientId`, since neither endpoint has a `caseId` query param). **No new bottom-nav tab, no firm-wide "all hearings"/"all documents" list screen this milestone.**
3. **Tasks placement**: no new nav tab. A personal pending-tasks section on the Dashboard (`GET /tasks` filtered client-side to `assignedToId == current user.id`, since there's no `?assignedToId=` query param either) + a Tasks section inside `CaseDetailsPage` filtered by `caseId`.

## Known backend issues to work around (not client bugs — flag, don't silently patch)

- **Hearings and Tasks `DELETE` are hard deletes** (`hearingRepository.remove()`/`taskRepository.remove()`, not `.softRemove()`), unlike Cases/Clients/Documents/Calendar-events. Irrelevant to M3 itself (read-only), but note it now so a future M4 delete-button doesn't assume soft-delete parity across every module.
- **`GET /documents/{id}` doesn't exist.** Document detail must come from the list response (`GET /documents`, filtered client-side to this case), not a dedicated fetch — same shape either way, just sourced differently than `CaseDetailsBloc`'s single-fetch pattern.
- **`GET /documents/{id}/download` is a stub**, not real file bytes or a presigned URL (`{message: 'File download simulated', url: '/uploads/...'}`). A "Download"/"Preview" action in the Documents section can show metadata (title, fileType, sizeBytes, uploadedBy, versionNumber) but **cannot fetch or render actual file content** this milestone — surfacing a disabled/"not yet available" download affordance rather than a broken one is the plan, not a workaround to fake around the stub.
- **Duplicate dead enum files exist for Hearings/Tasks/Calendar** (`enums/hearing-status.enum.ts`, `enums/task-status.enum.ts`, `enums/task-priority.enum.ts`, `enums/event-type.enum.ts`) with values that don't match the real (entity-file) enums actually used by the API. Building Dart enums from the entity-file values only, confirmed dead via `grep -rn` finding zero importers of the standalone files.
- **Relations-vs-DTO question — resolved, not just flagged (2026-07-30 re-verification):** confirmed `ClassSerializerInterceptor` is never applied anywhere in the codebase, and `plainToInstance` is only called in `ClientsController` (every endpoint) and the Documents *upload* response. Every other controller — Hearings, Tasks, Calendar, Documents' list, **and Cases** (see the M2 regression fix above, found during this same re-verification pass) — returns the raw entity, so the real shape is whatever each service's TypeORM `relations: [...]` array requests, full stop. **Freezed models for Hearing/TaskItem/DocumentItem/CalendarEventEntity are built against the relations-array-confirmed shape, not the documented DTO** — nested objects where the service's query actually requests that relation, nullable/ID-only where it doesn't (mirroring the `LegalCase` fix's reasoning exactly): `Hearing` nests `case`/`court` (both in `hearingsService`'s `relations`), `circuitId`/`hearingTypeId` stay ID-only (not loaded). `TaskItem` nests `case?`/`assignedTo`/`assignedBy` (all three in `tasksService`'s `relations`). `DocumentItem` nests `case?` only (`documentsService.findAll` loads `relations: ['case']` only — `uploadedBy`/`category` stay ID-only). `CalendarEventEntity` nests `user` (`calendarService.findAll` loads `relations: ['user']`) — `referenceId` stays opaque (never a relation, per its own design).
- **Calendar's `/timeline` response is loosely typed (`any[]`)** and merges three different item shapes (`CALENDAR_EVENT`/`HEARING`/`TASK`) with different field sets sharing a `date` key. This needs a sum-type Freezed model (or a plain `itemType`-discriminated parse), not a single flat class — see Freezed section below.
- **`/timeline`'s `userId` filter only restricts calendar events, not tasks** (confirmed via an explicit code comment in `calendar.service.ts`) — if the Calendar screen calls `/timeline?userId=...`, the tasks portion of the response is NOT actually scoped to that user despite the query param name suggesting otherwise. Don't rely on it for task filtering; keep task-scoping client-side same as the Dashboard's pending-tasks section.

## Freezed models needed

All four nest a `case`/`court`/`assignedTo`/`assignedBy`/`user` object exactly where that service's TypeORM `relations` array requests it (confirmed, see the resolved relations-vs-DTO note above) — **not** where the (unenforced) response DTO happens to document one. A nested `case` is a **thin `CaseSummary`**, not the full `LegalCase` — `relations: ['case', ...]` on Hearing/Task/Document loads only `Case`'s own columns, not `Case`'s *own* relations (client/team/etc. aren't cascade-loaded), so nesting the full `LegalCase` type would be wrong (its `required client`/`required team` fields would be absent here too).

- `CaseSummary { id, tenantId, caseNumber, status: CaseStatus, clientId, caseTypeId, primaryLawyerId?, defaultCourtId?, priority: CasePriority, openingDate?, closingDate?, outcomeSummary?, agreedFee?, createdAt, updatedAt }` — reuses the existing `CaseStatus`/`CasePriority` enums. Used wherever Hearing/Task/the `/timeline` payload nests a case; not the full `LegalCase`.
- `Hearing { id, caseId, case: CaseSummary?, courtId, court: Court?, circuitId?, hearingTypeId, scheduledAt, judgeName?, status: HearingStatus, outcomeText?, nextHearingAt?, createdAt, updatedAt }` (`case`/`court` nested — both in `hearingsService`'s `relations: ['case', 'court']`; `circuitId`/`hearingTypeId` stay ID-only, not loaded). `HearingStatus { scheduled, completed, adjourned, cancelled, unknown }` (real enum — `ADJOURNED`/`CANCELLED`, not the dead file's `POSTPONED`).
- `TaskItem { id, caseId?, case: CaseSummary?, assignedById, assignedBy: User?, assignedToId, assignedTo: User?, title, description?, priority: TaskPriority, status: TaskStatus, dueDate?, completedAt?, createdAt, updatedAt }` (`case`/`assignedTo`/`assignedBy` all nested — all three in `tasksService`'s `relations`; named `TaskItem`, not `Task`, same reasoning as `LegalCase` vs `case`). `TaskStatus { pending, inProgress, completed, cancelled, unknown }`, `TaskPriority { low, normal, high, urgent, unknown }` (confirms `URGENT` exists, corrects `MEDIUM`→`NORMAL` versus the dead enum file).
- `DocumentItem { id, title, description?, fileType, sizeBytes, caseId?, case: CaseSummary?, folderId?, categoryId?, uploadedById, versionNumber, createdAt, updatedAt }` (`case` nested — `documentsService.findAll` loads `relations: ['case']` only, so `uploadedBy`/`category` stay ID-only, not nested; named to avoid clashing with `dart:io`'s `File`/potential `Document` ambiguity).
- `CalendarEventEntity { id, tenantId, userId, user: User?, title, description?, eventType: CalendarEventType, referenceId?, startsAt, endsAt?, location?, isAllDay, createdAt, updatedAt }` (`user` nested — `calendarService.findAll` loads `relations: ['user']`) — replaces the mock `Appointment` model entirely (the mock conflates hearing+meeting+client-name into one flat shape that doesn't match anything real). `CalendarEventType { hearing, taskDeadline, custom, unknown }`. `referenceId` stays a plain opaque string — it's never a relation, by the endpoint's own design (a generic polymorphic link).
- `TimelineItem` — sum type over the three `/timeline` shapes (hand-built plain objects in `CalendarService.getTimeline`, not entities): a shared `date`/`title` plus a discriminated payload (`CalendarEventPayload{eventType, referenceId}`/`HearingPayload{status, case: CaseSummary?}`/`TaskPayload{status, priority, case: CaseSummary?}` — `case` here reuses the same `CaseSummary` type). Parsed from `itemType` string, `unknown` fallback for anything else.
- `DashboardMetrics { totalActiveCases, pendingTasks, upcomingHearings }` — thin, matches `GET /reports/dashboard` exactly (decision #1).

## Repositories

- `HearingRepository.getHearings()` → `GET /hearings` (full collection; `CaseDetailsBloc`-adjacent blocs filter client-side by `caseId`, same precedent as `ClientDetailsBloc`).
- `DocumentRepository.getDocuments()` → `GET /documents` (same client-side `caseId` filtering; no `getDocumentById` — the endpoint doesn't exist, see known-issues above).
- `TaskRepository.getTasks()` → `GET /tasks` (client-side filtered by `assignedToId` for Dashboard, by `caseId` for Case Detail — two different filters over the same fetched collection, same shape of decision as `CasesBloc`'s existing status/search dual-filter).
- `CalendarRepository.getTimeline({startDate, endDate, caseId?, userId?})` → `GET /calendar/timeline` (the one endpoint with real server-side filtering — use it as designed, don't also fetch-all-and-filter client-side here).
- `DashboardRepository.getMetrics()` → `GET /reports/dashboard` (decision #1).
- All four reuse the existing `mapDioError()` helper (`lib/core/network/dio_error_mapper.dart`) — no new error-mapping logic needed, same precedent as `CaseRepository`/`ClientRepository` in M2.

## Presentation

- **`CaseDetailsPage`**: add a Hearings section (fetch all hearings, filter by `caseId`, render list — reuse `EmptyState`/`ErrorView`) and a Documents section (same pattern, metadata-only, download affordance disabled per known-issues above) below the existing Team section. `CaseDetailsBloc` either grows to fetch hearings+documents alongside the case (mirroring `ClientDetailsBloc`'s secondary-fetch-doesn't-fail-the-screen pattern for each), or two new sibling blocs are added to the same `BlocProvider` scope — leaning toward the latter (keeps `CaseDetailsBloc` from becoming a 3-way fetch-and-merge, matches the Rule-of-Three guidance from the M2 retrospective by keeping each concern in its own bloc) but open to reconsidering once the actual widget composition is in front of you.
- **`DashboardPage`**: rebuilt from the current 100%-static mock into a real `DashboardBloc` calling `DashboardRepository.getMetrics()` + `TaskRepository.getTasks()` (filtered to the current user), replacing the 3 hardcoded summary cards and the hardcoded task list. The "today's schedule" and "recent clients" sections either get wired to `CalendarRepository.getTimeline()` (today's date range) and `ClientRepository.getClients()` (most-recently-created N) respectively, or are deferred — flagging this as a decision to confirm once we're implementing, not guessing the answer now.
- **`CalendarPage`**: `CalendarBloc` rebuilt against `CalendarRepository.getTimeline()` instead of the mock `Appointment` repository; `AppointmentDetailsPage` becomes a detail view keyed by `TimelineItem.itemType` (routes to the right sub-detail depending on whether it's a hearing/task/custom event). `NewAppointmentPage` (a write action) is out of scope for M3 — either hidden/unrouted this milestone (same treatment `sign_up_page.dart` got in M1) or left as-is pending M4, to confirm during implementation.
- Mock `Appointment`/`MockAppointmentRepository`/`GetAppointmentsUseCase` deleted once `CalendarBloc` no longer references them — same "no mock left" bar M1/M2 held to.

## Localization

New strings (hearing/document/task labels, status/priority labels, Dashboard's real metric labels) go to `assets/lang/*.json` — non-auth screens, same boundary M1/M2 established.

## Tests

- Repository tests (dio-mocked) for all four new repositories, same pattern as `case_repository_test.dart`/`client_repository_test.dart`, including unknown-enum-value fallback coverage for each new enum.
- Bloc tests for the two new `CaseDetailsPage` sibling blocs (hearings/documents), the Dashboard bloc, and the rebuilt `CalendarBloc`.
- At least one widget smoke test for the rebuilt `DashboardPage` and `CalendarPage` (loading/error/loaded, per the pattern `cases_page_test.dart`/`clients_page_test.dart` just established) — full EN/AR duplication across every screen remains a known, flagged gap rather than a blocking requirement, consistent with M2's precedent.

## Out of scope for M3 (explicitly deferred, not forgotten)

- Any write action anywhere (create/edit case, schedule/complete hearing, upload document, create/update task, notification preferences) — all of M4 per spec's original M3.
- Firm-wide standalone Hearings/Documents/Tasks list screens and any new bottom-nav tab (decisions #2/#3).
- Real file download/preview for Documents (backend stub, see known issues).
- `GET /dashboard` entirely — it's the System/Super Admin's platform-wide view, not something this tenant-scoped mobile client should ever call.
- `GET /reports/export/{cases,clients}` CSV export — no UI entry point planned before M4+.

## Definition of done

- [x] `Hearing`/`TaskItem`/`DocumentItem`/`CalendarEventEntity`/`TimelineItem`/`DashboardMetrics` models match the source-verified contract in `API_CONTRACT.md` finding I, fallback-safe enums using the entity-file values (never the dead `enums/` files).
- [x] Mock `Appointment`/`MockAppointmentRepository`/`GetAppointmentsUseCase` deleted; Dashboard's static mock content replaced with real data end-to-end.
- [x] Case Detail shows real Hearings and Documents sections, filtered client-side by `caseId`.
- [x] Dashboard shows real metrics from `GET /reports/dashboard` and a real personal task list; Calendar shows real data from `/calendar/timeline`.
- [x] Decisions #1-#3 implemented as specified above.
- [x] Repository + bloc tests for all new code; widget smoke tests for Dashboard and Calendar (loading/error/loaded/empty).
- [x] `flutter analyze` clean; `dart format` clean on every file touched.
- [x] `CLAUDE.md`/`PLAN.md` updated with outcomes (this pass).

### Not in this pass, flagged not forgotten
- A pre-existing M2 regression was found and fixed during this milestone's pre-planning re-verification (see session log) — `LegalCase.caseType`/`.primaryLawyer`/`CaseTeamMember.user` were wrongly `required`, and `CaseTeamMember.role` didn't match the real `roleOnCase` field. Fixed as its own commit before M3 feature work started, not folded into M3's own scope.
- Full EN/AR widget-test duplication for every M3 screen remains a known gap (English-only smoke coverage), consistent with the precedent M2 already established.

---

# Milestone 4 — Writes (Cases/Hearings update, Clients/Tasks full CRUD-minus-delete, Document upload, Calendar custom events)

**Status: DRAFT — awaiting review. No production code written yet.**

## Framing

Spec §15's original M3 ("Writes") assumed M2 already covered the full read-only workspace. This project's M2 covered Cases+Clients only, and M3 (just completed) filled in the rest (Hearings/Documents/Tasks/Calendar/Dashboard, read-only). M4 is now the actual "writes" milestone.

Before drafting, a Write Readiness Review (source-verified against `Hoqooq-main/`, not guessed) covered: auth/refresh behavior for mutations, error/validation mapping, repository patterns for POST/PATCH/DELETE/multipart, permission gating, optimistic-vs-refetch, and file upload architecture. Two things came out of that review that shape this plan directly:

1. **Clients module has no tenant scoping on `findOne`/`update`/`remove`** (confirmed cross-tenant read/write/delete by ID). **Per the user: the backend team is already aware and will fix this server-side — M4 proceeds with Client writes without waiting on it.** Documented in `API_CONTRACT.md` finding J for traceability, not treated as a client-side problem to solve.
2. **No endpoint anywhere lists `Lookup` rows** (`caseTypeId`/`hearingTypeId` reference this entity, and nothing exposes it — confirmed by grepping every controller, see finding J). This is a genuine, structural blocker: a Create-Case or Create-Hearing form has no way to populate a valid type dropdown. **Case and Hearing creation are out of scope for M4** — not a guess-around, an actual missing capability. Update for both is unaffected (the type field is just redisplayed read-only, never re-selected).

## Scope decisions (recommended — confirm before implementation)

| Module | Create | Update | Delete | Notes |
|---|---|---|---|---|
| **Clients** | ✅ | ✅ | — (deferred) | No Lookup dependency at all — every `CreateClientDto` field is free-form or an enum (`type`). Known tenant-scoping bug, proceeding per the user's instruction. |
| **Cases** | ❌ blocked | ✅ | — (deferred) | Create blocked on missing Lookup endpoint (`caseTypeId` required, unbrowsable). Update covers status/priority/dates/outcomeSummary/agreedFee/`defaultCourtId` (real via `GET /courts`)/`primaryLawyerId` (real via `GET /users`) — `caseTypeId` stays read-only in the edit form. |
| **Hearings** | ❌ blocked | ✅ | — (deferred) | Same Lookup blocker (`hearingTypeId`). Update covers status (this *is* "complete hearing" — PATCH `status: COMPLETED` + `outcomeText`), `scheduledAt`, `judgeName`, `nextHearingAt`, `courtId` (real). `circuitId` stays unset — optional field, but `CourtCircuit` has no controller either. |
| **Tasks** | ✅ | ✅ | — (deferred) | No Lookup dependency — `assignedById`/`assignedToId` are real `User` references via `GET /users`, not `Lookup` rows. |
| **Documents** | ✅ (upload only) | — (doesn't exist) | — (deferred) | Matches backend capability exactly: `POST /documents/upload` takes `file` + optional `caseId`, nothing else. No `PATCH`, no `GET /documents/{id}` — metadata can't be edited or individually re-fetched after upload, only re-read from the list. |
| **Calendar** | ✅ (`CUSTOM` events only) | — (not needed) | — (deferred) | `HEARING`/`TASK_DEADLINE` events aren't user-created — they're how `/timeline` aggregates real hearings/tasks server-side. The only meaningful calendar write is a custom personal event (title, description, start/end, location, all-day). |

**Delete is deferred across every module, not just where a backend blocker exists** — a deliberate scope cut, not a capability gap:
- Confirmed available: soft-delete on Cases/Clients/Documents/Calendar-events; hard-delete on Hearings/Tasks (both real, both callable) — no technical blocker either way.
- Reason for deferring anyway: delete needs its own confirmation-UX pass per module (hard vs. soft delete carries different messaging — "this cannot be undone" is only true for Hearings/Tasks), and spec's own original M3 wording ("create/edit case, schedule hearing, complete hearing, upload document, create/update task") never mentions delete at all. Keeping M4 to create/update keeps it focused; delete becomes its own follow-up milestone.

**Notification preferences (also in spec's original M3 wording) are also deferred** — no real endpoint exists for them. The generic `Settings` key-value store (`GET/POST/PATCH/DELETE /settings`) is a *different* entity than notification prefs would need, and using it for that purpose would be guessing an undocumented convention, not reading a documented one. Flagged, not built around.

## Known backend issues to work around (see `API_CONTRACT.md` finding J for full detail)

- Clients cross-tenant `findOne`/`update`/`remove` — known, backend team fixing, not blocking M4.
- No `Lookup`-listing endpoint — blocks Case/Hearing *create* specifically (not update). Revisit once available.
- `CourtCircuit` has no controller — `circuitId` stays unset in the Hearing form (optional field, not a blocker).
- `ValidationPipe`'s `forbidNonWhitelisted: true` — request bodies must contain **exactly** each DTO's field set, nothing extra, or the whole request 400s.
- `HttpExceptionFilter` collapses multi-field validation errors to the first one only (`message[0]`) — users fixing a form with several invalid fields will only see one error per submit attempt. Client-side pre-validation (required fields, date/UUID format) before submit reduces how often this bites.
- DELETE response status is inconsistent across modules (only Clients has a real `@HttpCode(204)`; everything else's documented 204 is Swagger-only, real default is 200) — moot for M4 (delete is deferred) but worth remembering whenever delete is picked up later: treat any 2xx as success, don't branch on the exact code.
- Seed data only grants permissions to the `admin` role (`lawyer`/`secretary`/`assistant`/`accountant` get none) — worth confirming a real test login can actually exercise permission-gated writes before assuming M4's screens are testable end-to-end in the current environment. Not a code-architecture concern.

## Freezed request models needed

Dedicated `Create*Request`/`Update*Request` models per module — never reusing a response entity's generated `toJson()` (it includes `id`/`createdAt`/nested objects that aren't on any DTO and would 400 under `forbidNonWhitelisted`). Field sets mirror each backend DTO exactly:

- `CreateClientRequest { clientCode, type: ClientType, fullName, nationalId?, commercialReg?, emails?, phones?, addresses? }` (no `tenantId` field client-side at all — see decision below), `UpdateClientRequest` — all fields optional, same set.
- `UpdateCaseRequest { primaryLawyerId?, defaultCourtId?, status?, openingDate?, closingDate?, outcomeSummary?, agreedFee?, priority? }` — deliberately **excludes** `caseTypeId`/`caseNumber`/`clientId` (immutable in this milestone's edit form; `caseNumber`/`clientId` aren't meant to change after creation regardless).
- `UpdateHearingRequest { courtId?, scheduledAt?, judgeName?, status?, outcomeText?, nextHearingAt? }` — excludes `caseId`/`hearingTypeId`/`circuitId`.
- `CreateTaskRequest { caseId?, assignedById, assignedToId, title, description?, priority?, status?, dueDate? }`, `UpdateTaskRequest` — same fields, all optional.
- `CreateEventRequest { userId, title, description?, eventType: CalendarEventType (always .custom here), startsAt, endsAt?, location?, isAllDay? }`.
- Document upload has no Freezed request model — built directly as `dio.FormData.fromMap({'file': MultipartFile.fromFile(path), if (caseId != null) 'caseId': caseId})`.

**`tenantId` decision:** `CreateCaseDto`/`CreateClientDto` both require a `tenantId` field server-side (validated for presence, `CasesService` discards and overrides it with the JWT-derived value; `ClientsService` does not override it at all — see finding J). Since the Flutter request models above don't expose a `tenantId` field to callers, the repository layer sources it once from `SessionCubit`'s current user (`user.tenant.id`, already available from `GET /users/me`) and injects it only at the wire-serialization boundary — never as a field a screen/bloc has to know about or supply. Confirm this approach before implementation: it satisfies the DTO's required-field validation without making any screen responsible for tenant plumbing.

## Repository additions

- `IClientRepository`: `+ createClient(CreateClientRequest)`, `+ updateClient(id, UpdateClientRequest)`.
- `ICaseRepository`: `+ updateCase(id, UpdateCaseRequest)`. No `createCase` this milestone.
- `IHearingRepository`: `+ updateHearing(id, UpdateHearingRequest)`. No `createHearing` this milestone.
- `ITaskRepository`: `+ createTask(CreateTaskRequest)`, `+ updateTask(id, UpdateTaskRequest)`.
- `IDocumentRepository`: `+ uploadDocument({required File file, String? caseId})`.
- `ICalendarRepository`: `+ createEvent(CreateEventRequest)`.
- All reuse `mapDioError()`; 400s specifically map to the already-defined-but-currently-dead `ValidationFailure` (finally wired up) instead of the generic `ServerFailure`, so write-failure UI can distinguish "fix your input" from "something broke."

## Presentation / bloc pattern for writes

- **Explicit refetch is the standard**, confirmed in the Write Readiness Review: no local cache exists to reconcile against, every list screen already does whole-collection-fetch-then-filter, and the backend's error-message collapsing makes a briefly-optimistic-then-reverted UI more confusing than it's worth here. After a successful create/update, the bloc re-dispatches the same fetch event the screen already uses (e.g., `CaseDetailsBloc` re-fetches after `UpdateCaseRequested` succeeds; `ClientsBloc` re-fetches the list after a create).
- Each write action gets its own bloc event (e.g., `UpdateCaseRequested(id, request)`) and a transient submission state (`CaseUpdateInProgress`/`CaseUpdateSuccess`/`CaseUpdateFailure`) layered onto the existing read state machine, not a replacement of it — mirrors how `AuthBloc`'s `LoginRequested` already coexists with session state in M1.
- One exception worth allowing, per the review: Task status toggles (marking complete) may update optimistically given how low-risk/reversible that single interaction is — to confirm as an explicit exception, not the default.
- Permission gating: hide create/edit affordances via `user.hasPerm('cases.update')` etc.; always handle a 403 gracefully regardless (BR-034) since UI gating is cosmetic only, especially given the `admin`/`client` role bypass and empty-permissions-for-other-roles findings above mean the actual authorization boundary is entirely server-side judgement, not something the UI can fully predict.

## File upload architecture (Documents)

- New dependencies needed (none currently in `pubspec.yaml`): `image_picker` (camera + gallery), `file_picker` (arbitrary file types), `permission_handler` (camera/photo-library runtime permissions on iOS/Android).
- Upload only — matches backend capability exactly. **Download/preview stays explicitly out of scope**: `GET /documents/{id}/download` is a confirmed non-functional stub (`{message: 'File download simulated', url: '/uploads/...'}`, no real bytes, no S3 wiring) — not something to build a UI around pretending it works.
- `dio`'s `onSendProgress` callback drives an upload-progress indicator — no existing convention for this in the codebase (nothing has needed progress reporting before), this introduces it as a new but expected pattern for a file-upload feature.
- Multipart + the refresh-retry interceptor: a 401 mid-upload would currently replay the same `FormData` instance via `RefreshInterceptor`'s retry path — `dio.MultipartFile.fromFile(...)`'s underlying stream is single-use, so this needs a fix (rebuild `FormData` fresh on retry when `requestOptions.data is FormData`, or exclude multipart requests from auto-retry and surface the error for a manual re-upload instead). Flagging as an implementation detail to get right, not a scope question.

## Localization

New strings (Edit Case/Edit Hearing/Create-Edit Client/Create-Edit Task/Create Event form labels, validation messages, upload progress/status text) go to `assets/lang/*.json`, same boundary M1–M3 established.

## Tests

- Repository tests for every new write method (dio-mocked): request-body shape asserted field-for-field against the exact DTO (catches `forbidNonWhitelisted` mismatches before they'd 400 for real), plus a 400→`ValidationFailure` mapping test (new coverage, since this path has been dead code until now).
- Bloc tests for each write event: submission state sequence (`...InProgress` → `...Success`/`...Failure`), and confirmation that success triggers the expected refetch dispatch.
- Widget tests for the new Create/Edit forms: field validation before submit, loading state during submission, error display on failure, success navigation/refresh — at least one per screen, following the established loading/error/loaded smoke-test pattern rather than full form-permutation coverage.

## Out of scope for M4 (explicitly deferred, not forgotten)

- Case creation, Hearing creation — blocked on the missing `Lookup`-listing endpoint. Revisit the moment one exists.
- Delete/archive for every module — deliberate scope cut (see above), not a backend gap. Own milestone.
- Notification preferences — no real backend endpoint exists yet.
- Document metadata edit, single-document re-fetch, document download/preview — none are supported server-side (see finding I/J).
- `circuitId` on Hearings — no browsable endpoint; stays unset.
- Fixing the Clients tenant-scoping gap — backend team's responsibility, not mobile's.

## Definition of done (draft — to convert to checkboxes once implementation starts)

- `Create*Request`/`Update*Request` models match each backend DTO's exact whitelisted field set (no extra keys, nothing that would trip `forbidNonWhitelisted`).
- Repository write methods for Clients (create+update), Cases (update), Hearings (update), Tasks (create+update), Documents (upload), Calendar (create custom event) — `tenantId` sourced from `SessionCubit`, never a screen-level concern.
- `ValidationFailure` finally wired into `mapDioError()` for 400s.
- Explicit-refetch-after-write implemented consistently across every new write bloc.
- Create/Edit screens for Clients, Tasks, Calendar events; Edit-only screens for Cases (type read-only) and Hearings (type read-only, status change covers "complete hearing"); Document upload flow with camera/file picker + progress.
- Multipart + token-refresh interaction fixed (fresh `FormData` on retry, or excluded from auto-retry).
- Repository + bloc + at least one widget test per new write path.
- `flutter analyze` clean; `dart format` clean on every file touched.
- `CLAUDE.md`/`PLAN.md`/`API_CONTRACT.md` updated with outcomes at milestone close.
