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

**Status: proposed, awaiting your approval. No code changes have been made yet.** Same scope as the superseded draft above (Cases + Clients, read-only list + detail) — this version is rewritten against the Case/Client shapes confirmed in the current `API_CONTRACT.md` (post backend update). The framing/reasoning for why M2 stays narrow (documents/tasks don't exist as features, hearings/calendar aren't a real feature split from the mock `Appointment` model, `case_details_page.dart`/`client_profile_page.dart` are fully hardcoded with no id parameter) is unchanged from the superseded draft above and not repeated here.

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

## Decisions needed before/while building

1. **Case Detail composition**: with `notes[]` gone and Timeline/Hearings/Documents still unbuilt, the only real content left is **Overview** (caseNumber, status, priority, caseType, openingDate/closingDate, outcomeSummary, agreedFee, client, defaultCourt) and **Team** (`team[]` → each member's `role` + `user`). No tabs beyond those two make sense to show. Confirm this is fine, or tell me if a different composition is wanted.
2. **`agreedFee` visibility**: BR-026 restricts case-fee visibility to Firm Admin / `finance.read`-holders. `User.isFirmAdmin` is still hardcoded `false` (no confirmed `role.code` value — see `CLAUDE.md`), and no permission-code value is confirmed either. Options: (a) show `agreedFee` to everyone for M2 since there's no reliable way to gate it yet (defers the BR-026 enforcement to whenever `isFirmAdmin`/permission codes are confirmed) — flagged as a **known, temporary BR-026 gap**, not silently ignored; (b) hide it entirely until gating is possible. I'd lean (b) — showing financially-sensitive data to everyone by default because gating isn't ready yet is the wrong failure direction for a finance-gated field — but this is your call, not mine to assume.
3. **Client's `emails[]`/`phones[]`/`addresses[]` — no "primary" flag**: the response gives plain string arrays with no indication of which (if any) is primary, unlike the BRD's intent (§8.3: "one primary" per array). Default: show all values in each array (e.g. a small list under "Emails", "Phones", "Addresses" rather than a single row), not guess at which one is primary.
4. **Client Detail's case list**: same limitation as before — no `GET /clients/{id}/cases` and no documented `?clientId=` filter on `GET /cases`. Default: fetch the full case list and filter client-side by `clientId`, same as the superseded draft's decision #2, still flagged as not scaling.
5. **Pagination/search**: still no query parameters documented on `GET /cases` or `GET /clients`. Same default as before: client-side search/filter over the full fetched list.
6. **Enum safety**: `CaseStatus`, `CasePriority`, `ClientStatus`, `ClientType` all modeled as Dart enums with an `unknown` fallback (`json_serializable`'s `unknownEnumValue`), since none of these lists are confirmed exhaustive.

## Checklist

### 1. Freezed models (per `API_CONTRACT.md` §5, §8)
- [ ] `Client { id, tenantId, clientCode, type: ClientType, fullName, status: ClientStatus, createdAt, updatedAt, nationalId?, commercialReg?, emails: List<String>, phones: List<String>, addresses: List<String> }`
- [ ] `Case { id, tenantId, caseNumber, status: CaseStatus, clientId, caseTypeId, priority: CasePriority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: CaseTypeLookup, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: List<CaseTeamMember> }`
- [ ] `CaseTypeLookup { id, name }` (nested-only — matches what `caseType` returns; no standalone lookups endpoint exists to back a separate feature)
- [ ] `Court { id, name, type, city?, address?, isActive }` (nested-only for M2, same as before — updated field names per the rebuilt shape)
- [ ] `CaseTeamMember { id, role: String, user: User }` (reuses the auth feature's `User` entity — `role` left as a raw string since no enum values are shown for it in any example, unlike the old `LEAD`/`SUPPORT` which at least had two observed values)
- [ ] `CaseStatus`/`CasePriority`/`ClientStatus`/`ClientType` enums with `unknown` fallback.

### 2. Repositories
- [ ] `CaseRepository` (replaces `MockCaseRepository`): `getCases()` → `GET /cases`, `getCaseDetails(id)` → `GET /cases/{id}`.
- [ ] `ClientRepository` (replaces `MockClientRepository`): `getClients()` → `GET /clients`, `getClientDetails(id)` → `GET /clients/{id}`.
- [ ] Repository tests (`mocktail`-mocked `Dio`), same pattern as `auth_repository_test.dart`.

### 3. Presentation
- [ ] `CasesBloc`/`ClientsBloc`: real repository calls, loading/error/empty states, `EmptyState`/`ErrorView`/skeleton loader (none of this exists on the current mock screens either — new work, not a regression).
- [ ] New `CaseDetailsBloc`/`ClientDetailsBloc` to fetch by id (don't exist today).
- [ ] `case_details_page.dart`/`client_profile_page.dart` rewritten to accept a real id from routing; `app_router.dart` routes updated to actually pass one.
- [ ] Case Detail: Overview + Team only, per decision #1. `agreedFee` handling per decision #2.
- [ ] Client Detail: `clientCode`, `type`, `status`, and the three contact arrays per decision #3. Case list per decision #4.
- [ ] List screens: client-side search/filter per decision #5.

### 4. Localization
- [ ] New strings in ARB, same convention as M1.

### 5. Tests
- [ ] Repository tests (dio-mocked, exact request shape against `API_CONTRACT.md`).
- [ ] Bloc tests for list + detail blocs.
- [ ] Widget tests in EN/LTR and AR/RTL, following the pumpAndSettle/localization-preload patterns documented in `CLAUDE.md`.

### Out of scope for M2 (unchanged from the superseded draft)
- Hearings, calendar, documents, tasks, dashboard.
- Any write action.
- Case timeline, case notes (notes capability didn't just stay missing — it was actively removed this update).
- Server-side search/filter/pagination.

## Definition of done
- [ ] `Case`/`Client` (+ nested `CaseTypeLookup`/`Court`/`CaseTeamMember`) models match the current `API_CONTRACT.md` exactly, fallback-safe enums.
- [ ] `MockCaseRepository`/`MockClientRepository` deleted.
- [ ] Case Detail and Client Detail take a real id from routing, render real data.
- [ ] Decisions #1-#6 resolved by your review (or your answers, where you want something other than the stated defaults — #2 in particular, where I stated a preference rather than a neutral default).
- [ ] All new/changed screens tested EN/LTR + AR/RTL; empty/loading/error states covered.
- [ ] `flutter analyze` clean; `dart format` clean on every file touched.
- [ ] `CLAUDE.md`/`PLAN.md` updated with outcomes.

---

Waiting for your review of this redraft — approve as-is (including stated defaults/preferences for decisions #1, #3, #4, #5, #6, and my *preference* — not default — for #2), or tell me what to change before I start.
