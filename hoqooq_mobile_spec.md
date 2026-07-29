# Hoqooq Mobile App — Build Spec for Claude Code

> **Target:** Flutter (iOS + Android) client for the Hoqooq Legal Practice Management Platform, v1.
> **Backend:** Existing tenant-scoped REST API (same one the web app uses). This app is a **client only** — it introduces no new endpoints and does not weaken any backend invariant.
> **Users of this app:** Firm users only — Firm Admin, Lawyer, Legal Secretary, Legal Assistant, Accountant.
> **NOT users of this app:** Super Admin (web-only), Clients (no login in v1), Opponents (no login ever).

---

## 1. Non-negotiable rules the app MUST respect

These come straight from the BRD business rules (BR-###). Violating any of these is a defect.

| ID | Rule | What the app must do |
|---|---|---|
| BR-003 | Tenant isolation, row-scoped | Every API call carries the user's JWT; the app never sends a `tenant_id` from the client — the backend derives it. Cross-tenant responses (404) surface as "Not found", never as "forbidden" (do not leak existence). |
| BR-005 | Firm Admin has full CRUD, non-restrictable | UI must not hide any module from a Firm Admin. |
| BR-007 | Clients are internal records, no login | No "client login" screen. No client-facing feature. |
| BR-010 | Subscription lifecycle | If backend responds `subscription_status = SUSPENDED` or `PAST_DUE-read-only`, the app enters **read-only mode**: all create/update/delete buttons disabled with a banner "Workspace is read-only — subscription lapsed. Contact your Firm Admin." Data still viewable. |
| BR-030 | Per-firm isolated RAG | AI chat only shows citations from the firm's own docs (backend guarantees this; the app just renders `sources[]`). |
| BR-032 | AI is advisory | Every AI output (summary, classification, chat answer) shows a badge "AI-generated — verify before use". A human edit overrides AI text. |
| BR-033 | Auth | Access token 15 min; refresh token 7 days with rotation. Store refresh token in **secure storage only** (Keychain / EncryptedSharedPreferences). Never in SharedPreferences plain. |
| BR-034 | RBAC at backend | UI hides disallowed actions **as UX**, but always assume the backend will reject too — handle 403 gracefully. |
| BR-036 | Encryption in transit | TLS 1.3 only. Cert pinning for prod API host. No cleartext HTTP. |
| BR-037 | Mobile/API parity | The app calls the same endpoints as web. No mobile-only "shortcut" endpoints. Every invariant that holds for web must hold here. |

---

## 2. Tech stack (opinionated — use unless a strong reason not to)

- **Framework:** Flutter (latest stable), Dart 3.
- **State management:** Riverpod 2.x (with code generation).
- **Routing:** `go_router` with declarative routes and guard redirects for auth + subscription state.
- **HTTP:** `dio` with interceptors for: auth header injection, refresh-token rotation, retry with exponential backoff, cert pinning, tenant/subscription-state banner triggers.
- **Local storage:**
  - Secure: `flutter_secure_storage` for tokens + biometric-unlock key.
  - Offline cache: `drift` (SQLite) for cached read models. Never cache sensitive full-content documents on disk unencrypted.
- **Localization:** Flutter's built-in `intl` + ARB files (`app_en.arb`, `app_ar.arb`). Enable RTL via `MaterialApp.builder` and `Directionality`. Test every screen in AR.
- **Push notifications:** Firebase Cloud Messaging (FCM) — iOS via APNs, Android via FCM. Register device token with backend endpoint `POST /devices`.
- **Biometrics:** `local_auth` for optional Face/Touch ID unlock of stored refresh token.
- **Date/time:** `intl` for locale-aware formatting; **all API times are UTC ISO-8601**, display in the firm's timezone (returned in `/me` response as `firm.timezone`).
- **Forms & validation:** `reactive_forms` or `flutter_hooks` + manual validators — pick one and be consistent.
- **Image capture (documents):** `image_picker` + camera; compress before upload.
- **Logging:** `logger` package; **no PII in logs** in release builds.
- **Analytics/crash:** Sentry or Firebase Crashlytics — scrub PII, tag only `tenant_id` (hashed) and `role`.

---

## 3. App architecture

```
lib/
  main.dart
  app.dart                    # MaterialApp + theme + locale + router
  core/
    api/                      # dio client, interceptors, error mapping
    auth/                     # login, refresh, biometric, session model
    storage/                  # secure storage + drift db
    localization/             # AppLocalizations, RTL utils
    theme/                    # light/dark, brand tokens
    rbac/                     # PermissionCheck widget + hasPerm() helper
    subscription/             # ReadOnlyGuard, banner state
    router/                   # go_router config, redirect guards
    notifications/            # FCM setup, deep links
    errors/                   # typed exceptions, user-facing messages
  features/
    auth/                     # login, mfa, password reset via invite token
    dashboard/
    cases/
    clients/
    opponents/
    hearings/
    calendar/
    courts/
    documents/
    tasks/
    finance/                  # accountant + firm admin only
    ai_assistant/
    notifications/
    profile/
    settings/                 # language toggle, theme, biometric, notif prefs
  shared/
    widgets/                  # AppScaffold, EmptyState, ErrorView, LoadingSkeleton
    models/                   # freezed data classes matching API DTOs
    formatters/               # currency, date, number (locale-aware)
test/
```

Each feature folder follows the same shape:
```
features/cases/
  data/         # repositories (call dio, cache in drift)
  domain/       # entities, use cases
  presentation/ # screens, widgets, providers
```

---

## 4. Auth & session flow

### 4.1 Login
1. User enters email + password.
2. `POST /auth/login` → returns `{ access_token, refresh_token, mfa_required: bool, user, firm, subscription_status, permissions[] }`.
3. If `mfa_required`: navigate to OTP screen → `POST /auth/mfa/verify` with `otp_code`.
4. Store `refresh_token` in secure storage. Keep `access_token` in memory only.
5. Store the `user`, `firm`, `permissions`, `subscription_status` in a Riverpod `SessionNotifier`.
6. Route to `/dashboard`.

### 4.2 Invitation activation (first-time Firm Admin or invited staff)
- Deep link: `hoqooq://activate?token=xxx` (and universal link fallback).
- Screen: set password → `POST /auth/activate { token, password }` → auto-login.

### 4.3 Refresh
- Dio interceptor: on `401`, call `POST /auth/refresh { refresh_token }`, retry once, rotate refresh token in secure storage. If refresh also fails → logout, route to `/login`.

### 4.4 Biometric unlock (opt-in)
- After first successful login, offer "Enable Face/Touch ID for faster login". If accepted, wrap access to refresh token with `local_auth`.
- Never bypass MFA with biometrics; biometric only replaces the password step of unlocking a stored refresh token on this device.

### 4.5 Logout
- Clear secure storage, drift cache, session state. Revoke device token: `DELETE /devices/{deviceId}`.

### 4.6 Lockout
- After 5 failed logins → backend returns `423` with a `retry_after` header → app shows a countdown, disables the login button.

---

## 5. Screens (feature by feature)

Every screen must: honor RTL when locale=AR, show `EmptyState` when zero results, show `ErrorView` with retry on failure, show a skeleton loader while fetching, and gate write actions behind `PermissionCheck` and `ReadOnlyGuard`.

### 5.1 Auth
- **Login** — email, password, "forgot password" link, language toggle in the top bar.
- **MFA verify** — 6-digit OTP.
- **Activate account** (invite link) — set password + accept terms.
- **Forgot password** — request reset (email).

### 5.2 Dashboard
- Greeting with user name + firm name + firm logo.
- Today's hearings card (list of up to 5, tap → hearing detail).
- Pending tasks assigned to me (count + top 3).
- Recent notifications (top 3).
- Quick actions: Create Case, Schedule Hearing, Upload Document, Create Task, New Invoice (each gated by permission).
- Revenue widget — **only if user has `finance.read` AND the Firm Admin has enabled it in settings**.

### 5.3 Cases
- **List** — search, filter by status (Draft/Active/Suspended/Closed/Archived) and primary lawyer. Infinite scroll.
- **Detail** — tabs: Overview, Team, Hearings, Documents, Tasks, Timeline, Finance (finance-gated).
  - Overview: case number, client, type, court, status, priority, dates, description.
  - Timeline: immutable events (BR-017), rendered oldest→newest with actor + timestamp.
- **Create / Edit** — draft first, then Activate action which enforces required fields (primary lawyer, opening_date, court, etc. — the backend validates; render the returned validation errors inline).
- **Actions gated by permission:** Change status, Reassign primary lawyer, Close case.

### 5.4 Clients
- **List** — search by name, phone, email, national ID/commercial reg.
- **Detail** — contact info, cases, financial summary (finance-gated), documents, notes.
- **Create / Edit** — duplicate warning if name+phone match; require justification to proceed.
- **Archive** (soft delete) — no physical delete from mobile.

### 5.5 Opponents
- **List / Detail / Create** — simpler than clients. Show all cases where this opponent appears (conflict-of-interest aid).

### 5.6 Hearings
- **List** — segments: Today, Upcoming, Past. Filter by court, lawyer, status.
- **Detail** — case, court + circuit, judge, scheduled_at (local TZ), status, outcome (if completed), attached minutes.
- **Schedule new hearing** — pick case → court → circuit → date/time → type → judge. Backend detects conflicts; render warnings, allow override with justification.
- **Complete** — outcome text (≥50 chars, BR-020), attach minutes document, set next_hearing_at (optional).
- **Reminders:** push notifications at 24h and 1h (backend fires these; the app just receives).

### 5.7 Calendar
- Month / Week / Day toggle.
- Color-coded: hearings (red), appointments (blue), task due dates (amber), reminders (grey).
- Tap event → detail of underlying entity.

### 5.8 Courts (Firm Admin / users with `court.manage`)
- **List / Detail / Create** with circuits as children.
- Deactivate (never delete when referenced).

### 5.9 Documents
- **List** — filter by entity (case/client/hearing/user), category, access level.
- **Upload** — pick file OR **take photo** (camera). Choose entity to link (required), category (required from firm lookups), access level.
- **Detail** — preview, version history, download, AI summary (if `ai_processed=true`), category (with AI suggestion badge if applicable).
- **Version restore** — Firm Admin only.
- Content is streamed from backend via signed URLs; never cache the raw file bytes to disk. Preview only in memory / temp file that is deleted on close.

### 5.10 Tasks
- **List** — segments: Assigned to me, Created by me, Overdue.
- **Detail / Create / Edit** — title, description, priority, due date, assignee, linked entity (case/client/hearing).
- **Status:** New → In Progress → Waiting → Completed → Cancelled.

### 5.11 Finance (Accountant + Firm Admin only)
- **Invoices list** — filter by status (Draft/Issued/Paid/Cancelled), client, case.
- **Invoice detail** — line items, totals, status. Issue action (irreversible per BR-027). Cancel action (only if not paid).
- **Payments** — record payment (invoice or case fee), method, reference, amount ≤ outstanding. **Immutable once saved** (BR-028). Correction = create compensating (reversal) entry (BR-029).
- **Expenses list / create** — categorized, receipt attachment required above threshold.
- **Case fee** — visible on case only if user has `finance.read`.

### 5.12 AI Assistant
- **Chat screen** — text input, streamed answer, source citations (chips linking to the source documents).
- Every answer footer: badge "AI-generated. Verify before relying on this."
- **Document actions** — from a document detail: "Summarize", "Suggest category", "Extract parties/dates/amounts". All advisory.
- Preflight: before firing an AI action, call `GET /ai/entitlement` — if credit exhausted or subscription not ACTIVE, show a friendly message and disable submit.

### 5.13 Notifications
- **In-app list** — hearings, task assignments, payment/subscription alerts, mentions.
- **Preferences** — per channel (push, email — email preference set here but delivered by backend), per event type. Persisted to `PATCH /me/notification_prefs`.

### 5.14 Profile & Settings
- Profile: name, avatar, email (read-only), role(s), MFA setup.
- Settings: language (EN / AR), theme (light / dark / system), biometric unlock toggle, notification prefs, about, logout.
- **Language change** must switch RTL/LTR live without app restart.

---

## 6. RBAC in the UI

Permissions arrive at login as `permissions: string[]` — codes like `cases.create`, `finance.read`, `documents.manage`.

Provide a helper:

```dart
bool hasPerm(String code) => ref.read(sessionProvider).permissions.contains(code)
    || ref.read(sessionProvider).permissions.contains(code.split('.').first + '.manage')
    || ref.read(sessionProvider).isFirmAdmin; // BR-005: firm admin is always allowed
```

And a widget:

```dart
PermissionCheck(
  perm: 'cases.create',
  child: FloatingActionButton(onPressed: _createCase, ...),
  fallback: SizedBox.shrink(),
)
```

The **seeded permission matrix from the BRD** — implement UI gating exactly to this. `own` means only records where the current user is the assigned lawyer / creator.

| Module | Firm Admin | Lawyer | Secretary | Assistant | Accountant |
|---|---|---|---|---|---|
| Firm settings & profile | ● | — | — | — | — |
| Staff management | ● | — | — | — | — |
| Roles & permissions | ● | — | — | — | — |
| Lookups | ● | R | R | R | R |
| Clients | ● | C R U (own) | C R U | R | R |
| Opponents | ● | C R U | C R U | R | R |
| Cases | ● | C R U (own) | R U | R | R |
| Hearings | ● | C R U (own) | C R U | R | R |
| Courts & circuits | ● | R | C R U | R | R |
| Documents | ● | C R U (own) | C R U | C R U | R |
| Tasks | ● | C R U (own) | C R U | C R U (own) | R |
| Calendar | ● | R U (own) | C R U | R | R |
| Finance | ● | — | — | — | ● |
| Case fee paid/remaining | ● | — | — | — | R |
| AI assistant | ● | C R | R | C R | R |
| Reports | ● | R (own) | R | R | R (finance) |
| Audit log | ● | — | — | — | — |

---

## 7. Data models (Dart / freezed)

Match the BRD data dictionary (Section 8). Use `freezed` + `json_serializable`. Example:

```dart
@freezed
class Case with _$Case {
  const factory Case({
    required String id,
    required String caseNumber,
    required String clientId,
    String? primaryLawyerId,
    String? caseTypeId,
    String? defaultCourtId,
    required CaseStatus status, // DRAFT, ACTIVE, SUSPENDED, CLOSED, ARCHIVED
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    double? agreedFee, // finance-gated: may be null in response if user lacks perm
    required CasePriority priority, // LOW, NORMAL, HIGH, URGENT
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Case;

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);
}
```

Model every entity from BRD Section 8: `User`, `Tenant` (firm), `Subscription`, `Client`, `Opponent`, `Case`, `CaseTeamMember`, `CaseTimelineEvent`, `Court`, `CourtCircuit`, `Hearing`, `Document`, `DocumentVersion`, `Invoice`, `InvoiceLineItem`, `Payment`, `Expense`, `Task`, `Lookup`, `AiUsageLedgerEntry`, `NotificationPreferences`.

---

## 8. Assumed API contract

The backend team will publish the OpenAPI spec. Base URL from `--dart-define=API_BASE_URL=...`. Endpoints follow REST with tenant-scoped auth. Illustrative set:

```
POST   /auth/login
POST   /auth/mfa/verify
POST   /auth/refresh
POST   /auth/activate
POST   /auth/forgot-password
GET    /me                          → user + firm + permissions + subscription_status
PATCH  /me/notification_prefs
POST   /devices                     → register FCM token
DELETE /devices/{id}

GET    /cases  ?status=&lawyer_id=&q=&page=&limit=
POST   /cases
GET    /cases/{id}
PATCH  /cases/{id}
POST   /cases/{id}/activate
POST   /cases/{id}/close
GET    /cases/{id}/timeline
GET    /cases/{id}/hearings
GET    /cases/{id}/documents
GET    /cases/{id}/tasks

GET    /clients ...   POST /clients   GET /clients/{id}   PATCH ...   POST /clients/{id}/archive
GET    /opponents ...
GET    /hearings ?range=today|upcoming|past
POST   /hearings
POST   /hearings/{id}/complete       body: { outcome_text, next_hearing_at?, minutes_document_id? }
GET    /courts   POST /courts   ... /courts/{id}/circuits

GET    /documents ?entity_type=&entity_id=&category_id=
POST   /documents                    → multipart upload
GET    /documents/{id}/download-url  → signed URL, short TTL
GET    /documents/{id}/versions
POST   /documents/{id}/versions/{v}/restore

GET    /tasks ?assigned_to_me=&overdue=
POST   /tasks

GET    /invoices   POST /invoices   POST /invoices/{id}/issue   POST /invoices/{id}/cancel
POST   /payments
POST   /payments/{id}/reverse
GET    /expenses   POST /expenses

GET    /ai/entitlement               → { remaining_credits, allowed_features }
POST   /ai/chat                      → SSE / streaming
POST   /documents/{id}/ai/summarize
POST   /documents/{id}/ai/classify
POST   /documents/{id}/ai/extract

GET    /notifications ?unread=
POST   /notifications/{id}/read
```

**Standard error envelope** to expect:
```json
{ "error": { "code": "PERMISSION_DENIED", "message": "…", "details": {...} } }
```
Map codes to user-facing localized messages in `core/errors/`.

**Subscription-state header:** the API includes `X-Subscription-Status: ACTIVE|PAST_DUE|SUSPENDED` on every response. The dio interceptor updates `SessionNotifier.subscriptionStatus` which drives the `ReadOnlyGuard`.

---

## 9. Localization & RTL

- All user-facing strings live in `app_en.arb` / `app_ar.arb`. No hard-coded strings.
- Numbers, currency, and dates use `intl` with the firm's `currency` and `timezone`.
- Icons that imply direction (back arrow, chevrons, list bullets) must mirror in RTL. Prefer `Directionality`-aware widgets; avoid `EdgeInsets.only(left: ...)` — use `EdgeInsetsDirectional.only(start: ...)`.
- Test every screen with `Directionality(textDirection: TextDirection.rtl, ...)` widget tests.
- Lookups from the API return both `label_en` and `label_ar`; render based on current locale.

---

## 10. Offline strategy

**Read-only cache** for:
- Recently viewed cases, clients, hearings (last 30 days accessed).
- Today's dashboard payload.
- Firm settings + user profile + permissions (for offline permission checks).

**Writes while offline:**
- Queue: create task, update task status, add note to case. Small mutations only.
- Do NOT queue: create/edit invoices, record payments, upload documents, activate cases — these must be online.
- Sync queue on reconnect; if backend rejects due to conflict or permission change, surface a clear error and let user decide.

**Never cache offline:**
- Document file bytes.
- Financial totals older than the current session (must re-fetch on view).
- Authentication material beyond the encrypted refresh token.

Use `connectivity_plus` to detect network state; show an offline banner.

---

## 11. Push notifications

- Firebase project set up for both platforms; APNs certificate/key uploaded for iOS.
- On login → get FCM token → `POST /devices { token, platform, app_version }`.
- On logout → `DELETE /devices/{id}`.
- Notification types the backend will send:
  - `hearing_reminder_24h`, `hearing_reminder_1h`
  - `task_assigned`, `task_due_soon`
  - `payment_recorded`, `invoice_issued`
  - `subscription_past_due`, `subscription_suspended`
  - `mention`
- Payload includes `type`, `entity_type`, `entity_id` → tap opens the correct deep link (via `go_router`).
- Foreground notifications: show local snackbar/banner. Background: OS system notification.

---

## 12. Security checklist

- [ ] TLS 1.3 enforced; HTTP blocked in production build.
- [ ] Certificate pinning for prod API host (rotate policy documented).
- [ ] Refresh token stored via `flutter_secure_storage` (Keychain / EncryptedSharedPreferences).
- [ ] Access token in memory only; never persisted.
- [ ] Screenshot blocking on sensitive screens (login, MFA, finance, documents) — `FLAG_SECURE` on Android; iOS blur on background.
- [ ] Jailbreak / root detection — warn user, do not block, but log.
- [ ] Biometric unlock is opt-in and does not replace MFA on first login from a new device.
- [ ] No PII in logs or crash reports (scrub before send).
- [ ] Debug-only endpoints stripped from release builds.
- [ ] Third-party SDKs audited; no analytics that ship user content.
- [ ] Session ends → clear secure storage, drift DB, in-memory state.
- [ ] Deep links validated (no open redirect via `hoqooq://…`).

---

## 13. Testing

- **Unit:** business logic (RBAC helper, subscription-state guard, form validators, currency/date formatters, offline queue).
- **Widget:** every screen in both EN LTR and AR RTL; empty / loading / error states; permission-gated variants.
- **Integration:** login → dashboard → view case → schedule hearing → receive push (simulate) → complete hearing.
- **Golden tests** for critical screens in both directions.
- **No-leak probe (mirror BR-003):** attempt to fetch a case from a foreign tenant ID → expect 404, assert app shows "Not found", not "Forbidden".
- CI runs `flutter test` + `flutter analyze` + `dart format --set-exit-if-changed`.

---

## 14. Build & deploy

- Environments via `--dart-define`: `dev`, `staging`, `prod` (different `API_BASE_URL`, Firebase config, cert pins).
- Flavors: `dev`, `staging`, `prod` with distinct bundle IDs and icons.
- iOS: TestFlight for staging + prod.
- Android: internal testing track → closed beta → production.
- Versioning: `MAJOR.MINOR.PATCH+BUILD`; bump build on every CI run.

---

## 15. Delivery milestones (suggested)

1. **M1 — Foundation:** project setup, theming, i18n (EN + AR + RTL), routing, dio client + interceptors, secure storage, session provider, auth screens, `/me` fetch.
2. **M2 — Read-only workspace:** dashboard, cases list + detail, clients list + detail, hearings list + detail, calendar, documents list + preview, tasks list.
3. **M3 — Writes:** create/edit case, schedule hearing, complete hearing, upload document (camera + file), create/update task, notifications preferences.
4. **M4 — Finance:** invoices, payments, expenses, case-fee visibility gate.
5. **M5 — AI assistant:** chat, summarize, classify, extract, credit preflight.
6. **M6 — Polish:** offline cache, push notifications end-to-end, biometric unlock, screenshot blocking, cert pinning, golden tests, RTL audit pass, accessibility pass.

---

## 16. Definition of done

- All 37 BR-### rules relevant to a client app are respected (checklist in code review).
- Every user-facing string localized in EN + AR; screens verified in RTL.
- Read-only mode kicks in correctly on `X-Subscription-Status: SUSPENDED`.
- Cross-tenant fetch returns 404 and app surfaces "Not found".
- Push notification tap deep-links to the correct entity.
- Documents uploaded from camera reach the correct entity with correct category.
- AI outputs always show the advisory badge (BR-032).
- Tests, analyzer, and formatter all green in CI.
- App runs on iOS 14+ and Android 8 (API 26) +.

---

## Appendix A — Key BRD references

This spec is derived from **Hoqooq BRD v1.0**. When in doubt, defer to:
- Section 3 (Actors) — who this app is for.
- Section 6.2 (Firm Workspace Modules) — feature detail per module.
- Section 6.3 (Mobile Application) — mobile-specific scope.
- Section 7 (Business Rules BR-001 … BR-037) — non-negotiable behavior.
- Section 8 (Data Dictionary) — DTO shapes.
- Section 9 (RBAC matrix) — permission gating source of truth.
- Section 10 (Cross-cutting: localization, notifications, NFRs).

Ask the backend team for the OpenAPI spec before locking DTOs and endpoint paths; the shapes above are the expected contract based on the BRD but should be reconciled with the served spec.
