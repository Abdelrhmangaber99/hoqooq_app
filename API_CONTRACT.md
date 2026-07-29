# Hoqooq API Contract

**Source:** `hoqooq-postman-import.json` (87 requests, Postman Collection v2.1, `_postman_id: 0d05367b-0d3a-4c07-a99e-248fd3ff53b5`). Regenerated 2026-07-30 after the user replaced the file with an updated export — this is a **second, structurally different** version of the contract. See "Breaking changes since the M1 version" immediately below before assuming anything from the previous contract still holds.

Per project instructions, this file is the source of truth for all HTTP calls.

---

## ⚠️ Breaking changes since the M1 version of this file (2026-07-30, same day)

This is not a re-randomization of examples — the collection went from 97 requests to 87, gained a global `/api` prefix, and several core entities were structurally rebuilt to match the BRD's actual data dictionary far more closely. Full diff method available: old export preserved as `/tmp/postman_full.json` from the M1 session, new one at `/tmp/postman_full_v2.json` (both outside the repo).

### 1. Every path now has an `/api` prefix
Old: `POST /auth/login`. New: `POST /api/auth/login`. This applies to **all 87 endpoints, no exceptions**. `ApiConfig.baseUrl` (or every call site) needs this prefix added — nothing in M1's shipped code has it yet.

### 2. `GET /users/me`, `/users`, `/users/{id}` — User shape rebuilt (breaks M1's `User`/`Role`/`Permission` entities)
| Field | M1 version | Current version |
|---|---|---|
| Name | `firstName` + `lastName` (both required) | Single `fullName` string |
| Active flag | `isActive: boolean` | `status: string` (enum-shaped, matches BRD's `INVITED/ACTIVE/SUSPENDED/DEACTIVATED`) |
| New fields | — | `isSuperAdmin: boolean`, `mfaEnabled: boolean` |
| `roles[]` shape | `{id, name, displayNameEn, displayNameAr, permissions[]}` | `{id, code, scope, permissions[]}` — **no more `name`/`displayNameEn`/`displayNameAr`** |
| `permissions[]` shape | `{id, resource, action, displayNameEn, displayNameAr}` | `{id, code}` — **no more `resource`/`action` split, no more display names** |

**Impact:** `lib/features/authentication/domain/entities/user.dart`'s `fromJson` will throw immediately on a real response — `firstName`/`lastName`/`isActive` are marked `required` and no longer exist. `User.fullName` (the computed getter) is now redundant since the API provides it directly. `User.hasPerm(resource, action)` no longer has a `resource`/`action` pair to check against — permissions are now a single `code` string, so the method signature itself needs to change to `hasPerm(String permissionCode)`. This also **resolves** the "how would `isFirmAdmin` ever be detected" open question differently than expected: `role.code` (e.g. plausibly `"FIRM_ADMIN"`) is a much more promising signal than the old `role.name`/`displayNameEn` fields were, though still no example shows a real value — `<string>` placeholders throughout, same caveat as before.

Auth endpoints themselves (`login`, `signup`, `refresh`, `logout`, `forgot-password`, `reset-password`, `change-password`) are **byte-for-byte unchanged** except for the `/api` prefix — confirmed by diffing every field. M1's `AuthRepository`/`AuthBloc`/token logic does not need to change beyond the base URL.

### 3. `GET/POST/PATCH /cases`, `GET /cases/{id}` — Case shape completely rebuilt
| | M1/previous version | Current version |
|---|---|---|
| Removed fields | `title`, `description`, `type`, `courtId`, `court{}`, `assignments[]`, `notes[]` | — |
| Added fields | — | `tenantId`, `caseTypeId` + `caseType{id,name}` (lookup-based, replaces free-text `type`), `primaryLawyerId` + `primaryLawyer{User}` (singular, replaces `assignments[]`), `defaultCourtId` + `defaultCourt{Court}` (renamed from `courtId`/`court`), `openingDate`, `closingDate`, `outcomeSummary`, `agreedFee`, `priority`, `team[]` (replaces `assignments[]`, shape now `{id, role, user: {User}}` instead of `{id, role, employee: {Employee}}`) |
| `POST /cases/{id}/assignments` | existed | **endpoint removed entirely** |
| `POST /cases/{id}/notes` | existed | **endpoint removed entirely** — no note-adding capability exists anywhere now, and `notes[]` is gone from the response too |

This is now dramatically closer to BRD §8.4 `cases` (agreed_fee, priority, opening/closing dates, primary_lawyer_id, case_type_id as a lookup) than the old version was. **Any M2 planning built against the old Case shape (title/description/assignments/notes) is void.**

### 4. `GET/POST/PATCH /clients`, `GET /clients/{id}` — Client shape completely rebuilt
| | Previous version | Current version |
|---|---|---|
| Removed | `name`, `email`, `phone`, `address`, `taxId` (all singular) | — |
| Added | — | `tenantId`, `clientCode`, `fullName`, `status`, `nationalId`, `commercialReg`, `emails[]`, `phones[]`, `addresses[]` (all arrays now) |

Now matches BRD §8.3 `clients` almost exactly (client_code, national_id/commercial_reg, multi-value contact arrays, status enum). **Any M2 planning built against the old Client shape is void.**

### 5. Modules removed entirely
- **`employees`** (5 endpoints: onboard, list, get, update, delete) — the whole staff-management surface is gone. BRD §6.2.3 Staff Management now has **zero backing** in this API (previously it existed, just with the wrong role/department taxonomy — now there's nothing at all).
- **`reviews`** (2 endpoints) and **`consultations`** (1 endpoint) — the public lawyer-marketplace/review/booking surface flagged as a BR-violation in the M1 version of this file is now **gone**. This resolves that concern; no action needed.
- Net: 10 endpoints removed, 0 added, 87 remain.

### 6. Other structural changes worth knowing before touching a given module
- **Opponents**: lost `email` and `notes` fields; now just `{type, name, phone, address}`.
- **Courts**: `location`/`contactInfo` renamed to `city`/`address`; gained `isActive`.
- **Tasks**: gained `assignedById` (alongside `assignedToId`); `status` enum changed from `TODO/IN_PROGRESS/DONE` to `PENDING/IN_PROGRESS/COMPLETED/CANCELLED`; gained `completedAt`.
- **Documents**: `name` renamed to `title`; gained `fileType` (renamed from `contentType`), `sizeBytes` (renamed from `size`), `uploadedById`, `versionNumber`, `folderId`, `categoryId`. Still no `GET .../versions` endpoint — `versionNumber` is a counter, not a browsable history.
- **Hearings**: gained `hearingTypeId`, `circuitId`, `judgeName`, `outcomeText`, `nextHearingAt`; `status` enum is now `SCHEDULED/COMPLETED/ADJOURNED` (matches BRD, no more `POSTPONED`).
- **Calendar events**: `date`+`time`(string) replaced by proper `startsAt`/`endsAt` datetimes; gained `eventType: CUSTOM|TASK_DEADLINE|...`, `referenceId` (generic link, likely to case/hearing/task), `location`, `isAllDay`, `tenantId`.
- **Invoices**: flat `amount` replaced by `subtotal`/`taxTotal`/`grandTotal`; gained proper `invoiceNumber`; `status` gained `PARTIAL`.
- Still **no error-envelope example anywhere** — every 4xx/5xx response in all 87 requests has an empty body, same gap as before, not newly discovered.
- Still **no subscription/billing surface, no MFA endpoint, no case-timeline endpoint, no document-versions-list endpoint** — all gaps flagged in the M1 version of this file persist unchanged.
- `POST/PATCH /users`, `POST/PATCH /cases` **still accept a client-supplied `tenantId`** in the request body — the BR-003 concern flagged in M1 is unchanged and has spread to `/cases` too now.
- Collection description changed from "Multi-Tenant SaaS Legal Practice Management System" to "Legal Practice Management System" — cosmetic, but noting it since "Multi-Tenant SaaS" was dropped from the wording.

---

## Base URL & auth (unchanged mechanics, changed path)

**Base URL:** collection variable `baseUrl = "/"` — still a placeholder, still no real dev/staging/prod host. **All paths below already include the `/api` prefix** — `ApiConfig.baseUrl` should point at the host only (e.g. `http://localhost:3000`), with `/api` prepended to every path, OR `/api` gets folded into the base URL itself (e.g. `http://localhost:3000/api`) — implementation detail to settle before any M2 code, not decided here.

**Auth scheme:** unchanged — `Authorization: Bearer <token>` on all but `login`/`signup`/`refresh`/`forgot-password`/`reset-password`/`settings/public`. (Note: `GET /api/reviews/lawyer/{lawyerId}` no longer exists since `reviews` was removed — the no-auth-required list shrank by one for that reason alone.)

**Naming convention:** still camelCase throughout.

---

## 1. Auth — unchanged from M1 except path prefix

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/api/auth/login` | none | `{email, password}` → `{accessToken, refreshToken, user: {}}`. Byte-identical to M1 version. |
| POST | `/api/auth/signup` | none | Still exists, still contradicts BR-001. `{email, password, firstName, lastName, userType, firmName}` — note this request still uses `firstName`/`lastName` even though the `User` model itself moved to a single `fullName`; not reconciled in this collection. |
| POST | `/api/auth/refresh` | none | `{refreshToken}` → `{accessToken, refreshToken, user: {}}`. |
| POST | `/api/auth/logout` | bearer | `{refreshToken}` → 204. |
| POST | `/api/auth/forgot-password` | none | `{email}` → 200. |
| POST | `/api/auth/reset-password` | none | `{token, newPassword}` → 204. |
| POST | `/api/auth/change-password` | bearer | `{oldPassword, newPassword}` → 204. |

Still missing: `/auth/mfa/verify`, `/auth/activate`. Still no device/FCM registration endpoint.

## 2. Users / Roles / Permissions — shape rebuilt (see breaking change #2)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/users` | `{email, password, fullName, avatarUrl?, isSuperAdmin?, tenantId, roleIds[]}` | 201 User |
| GET | `/api/users` | — | 200 User[] |
| GET | `/api/users/me` | — | 200 User |
| GET | `/api/users/{id}` | — | 200 User |
| PATCH | `/api/users/{id}` | `{email?, fullName?, avatarUrl?, isSuperAdmin?, tenantId?, roleIds[]?}` | 200 User |
| DELETE | `/api/users/{id}` | — | 200 (empty) |
| GET | `/api/roles` | — | 200 (no example body — still undocumented) |
| GET | `/api/roles/permissions` | — | 200 (no example body — still undocumented) |

**User** = `{id, email, fullName, isSuperAdmin, status, mfaEnabled, createdAt, updatedAt, avatarUrl?, lastLoginAt?, roles: Role[], tenant: {id, name}}`
**Role** = `{id, code, scope, permissions: Permission[]}`
**Permission** = `{id, code}`

`tenantId` is still client-suppliable in `POST`/`PATCH /users` bodies — same BR-003 concern as M1, unresolved.

## 3. Public / Tenants — unchanged (still present, still a BR-scope concern)

`GET /api/public/lawyers`, `GET /api/public/lawyers/specializations` (bearer, despite the name) — still a marketplace-style directory the BRD lists as out-of-scope. `GET /api/settings/public` (none). `GET/PATCH /api/tenants/my-firm`, `POST /api/tenants/my-firm/logo`, and the System-Admin-only `GET/PATCH/DELETE /api/tenants`/`/api/tenants/{id}` — all unchanged from M1, all the same concerns (cross-tenant System-Admin endpoints sitting in the same flat collection as firm-scoped ones; hard `DELETE` on a tenant contradicts BR-013).

## 4. Notifications — unchanged

`GET /api/notifications/me` → `[{id, userId, title, message, isRead, type, createdAt}]`. `PATCH /api/notifications/{id}/read`. Same gap as before: no `/me/notification_prefs`, no device registration.

## 5. Clients — shape rebuilt (see breaking change #4)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/clients` | `{tenantId, clientCode, type: INDIVIDUAL\|COMPANY, fullName, nationalId?, commercialReg?, emails[], phones[], addresses[]}` | 201 Client |
| GET | `/api/clients` | — | 200 Client[] |
| GET/PATCH/DELETE | `/api/clients/{id}` | (PATCH same fields, optional) | 200 / 200 / 204 |

**Client** = `{id, tenantId, clientCode, type, fullName, status, createdAt, updatedAt, nationalId?, commercialReg?, emails: string[], phones: string[], addresses: string[]}`. Note `emails`/`phones`/`addresses` are arrays of plain strings in the examples, not objects with a "primary" flag — BRD wanted one designated primary per array (§8.3); this collection doesn't show how (or if) that's represented. `DELETE` is still a hard delete (still contradicts spec's "archive only" expectation, still worth flagging before wiring a delete button to it).

## 6. Opponents — minor shape change

`{type, name, phone?, address?}` — **`email` and `notes` fields are gone** compared to the M1 version. POST/GET/PATCH/DELETE all otherwise the same shape (`id, type, name, createdAt, updatedAt, phone?, address?`). Still no representative_name/representative_contact (BRD §8.3). DELETE still hard.

## 7. Courts — shape adjusted

`{name, type, city?, address?, isActive}` (was `location`/`contactInfo`, now `city`/`address`). Still no court_circuits endpoints. DELETE still hard (contradicts BR-021's "deactivate, don't delete").

## 8. Cases — shape rebuilt (see breaking change #3)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/cases` | `{tenantId, caseNumber, clientId, caseTypeId, primaryLawyerId, defaultCourtId, status, openingDate?, closingDate?, outcomeSummary?, agreedFee?, priority}` | 201 Case |
| GET | `/api/cases` | — | 200 Case[] |
| GET | `/api/cases/{id}` | — | 200 Case |
| PATCH | `/api/cases/{id}` | same fields as POST, all optional | 200 Case |
| DELETE | `/api/cases/{id}` | — | 204 |

**Case** = `{id, tenantId, caseNumber, status, clientId, caseTypeId, priority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: {id, name}, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: [{id, role, user: User}]}`.

**No more `title`, no more free-text `description`, no more `assignments[]`/`notes[]`, no more `POST /cases/{id}/assignments` or `/notes` endpoints.** `status` examples seen: `DRAFT`, `ACTIVE`, `ARCHIVED` (still not a documented exhaustive list). `priority` examples seen: `NORMAL`, `HIGH`, `URGENT` (BRD's 4th value `LOW` not observed but plausible). This is much closer to BRD's case model than before, but the loss of any note-taking or hearings/documents sub-resources on the case itself means a Case Detail screen now has **less** to show than the previous (mock) version assumed, not more — only Overview + Team via `team[]`.

## 9. Tasks — shape adjusted

`{assignedById, assignedToId, title, caseId?, description?, priority, status, dueDate?}` request; response adds `completedAt?`. `status` enum now `PENDING/IN_PROGRESS/COMPLETED/CANCELLED` (was `TODO/IN_PROGRESS/DONE`). `priority` seen: `LOW/NORMAL/HIGH` (URGENT not observed but plausible given the pattern elsewhere). No `entity_type` polymorphic linking — only `caseId`, same limitation as before.

## 10. Documents — shape adjusted

`POST /api/documents/upload` (multipart: `file` required, `caseId` text) → `{id, title, fileType, sizeBytes, uploadedById, versionNumber, createdAt, updatedAt, description?, caseId?, folderId?, categoryId?}`. `GET /api/documents/{id}/download`, `DELETE /api/documents/{id}` (still hard delete), `GET /api/documents`. Still no versions-list/restore endpoints despite `versionNumber` existing on the model — you can see which version you're on, not browse or restore prior ones.

## 11. Hearings — shape adjusted, now closer to BRD

`{caseId, courtId, hearingTypeId?, scheduledAt, circuitId?, judgeName?, status, outcomeText?, nextHearingAt?}`. `status` enum now `SCHEDULED/COMPLETED/ADJOURNED` (was `SCHEDULED/COMPLETED/POSTPONED`) — matches BRD's hearings model (§8.4) almost exactly now, including `circuitId` (though still no nested circuit object or standalone circuits endpoint) and `outcomeText`/`nextHearingAt` (BR-020). Still no `/complete` action — just a raw `status` field via PATCH. DELETE still hard (BR-020 implies completed hearings should be permanent).

## 12. Finance — shape adjusted

**Invoices**: `{clientId, invoiceNumber, subtotal, taxTotal, grandTotal, issueDate, dueDate, caseId?, status, notes?}` + nested `payments[]`. `status` now includes `PARTIAL` (was `DRAFT/ISSUED/PAID/CANCELLED`, examples now show `PARTIAL/PAID/CANCELLED` — union unclear, not exhaustively documented). Still flat totals, no line-items endpoint (BRD's `invoice_line_items`). **Payments**: unchanged shape, `{invoiceId, amount, paymentDate, method, referenceNumber?}`. **`DELETE` still exists on both invoices and payments — still directly contradicts BR-028/BR-029 (no physical deletion of financial records).** Still no reversal/compensating-transaction endpoint. Still no expenses module at all.

## 13. Calendar — shape adjusted, now closer to BRD's unified-calendar concept

`{userId, title, eventType: CUSTOM|TASK_DEADLINE|..., startsAt, endsAt?, description?, referenceId?, location?, isAllDay}` + `tenantId` in the response. `eventType: TASK_DEADLINE` appearing in examples is a good sign this is meant to aggregate task due dates as the spec's Calendar screen wants (§5.7) — but there's still no confirmed value for a hearing-derived event type, so it's unclear whether `GET /calendar` alone will surface hearings too, or whether the mobile app still needs to separately merge `/hearings` in. `GET /calendar/timeline` (query: `startDate, endDate, caseId, userId`) still has no example response — still the best candidate for "the" aggregation endpoint, still unconfirmed. DELETE still hard.

## 14. Reports & Dashboard — unchanged

Both `GET /api/reports/dashboard` (`{totalActiveCases, pendingTasks, upcomingHearings}`) and `GET /api/dashboard` (`{totalCases, activeCases, pendingTasks, upcomingHearings, totalInvoices, unpaidInvoices, recentActivity[]}`) still exist, still overlapping, still unresolved which one the mobile Dashboard should call. `GET /reports/export/{cases,clients}` unchanged (CSV, no example).

## 15. Settings — unchanged

Generic key-value store, same as M1 version. Same limitation: no typed lookups endpoint for case types/hearing types/document categories/expense categories (though `caseType: {id, name}` appearing nested in Case responses now confirms **lookups do exist as real entities server-side** — there's just still no dedicated `GET /lookups?kind=...`-style endpoint exposed in this collection to fetch them standalone).

## 16. AI Assistant — unchanged

`POST /api/ai/summarize`, `/api/ai/research`, `/api/ai/chat` — still no example bodies, still no entitlement/credit-preflight endpoint, still no classify/extract actions. Same gaps as M1 version.

## 17. Modules removed since M1 (see breaking change #5)

`employees` (all 5 endpoints), `reviews` (2 endpoints), `consultations` (1 endpoint) — gone. `POST /cases/{id}/assignments` and `POST /cases/{id}/notes` also gone (folded into the Case rebuild above).

---

## Gap Analysis Summary (updated)

### Resolved since the M1 version of this file
- Marketplace reviews/consultations endpoints — removed entirely, no longer a concern.
- Case model now has `agreed_fee`, `priority`, `opening_date`/`closing_date`, `primary_lawyer_id`, `case_type_id` as a lookup — all previously-flagged BRD gaps, now present.
- Client model now has `client_code`, `national_id`/`commercial_reg`, multi-value contact arrays — previously-flagged BRD gaps, now present.
- Hearings model now has `hearing_type_id`, `circuit_id`, `judge_name`, `outcome_text`, `next_hearing_at`, and the correct `SCHEDULED/COMPLETED/ADJOURNED` status enum — previously-flagged gaps, now present.

### Still open (unchanged from M1 version)
- No MFA endpoint, no invite-activation endpoint, no device/FCM registration, no `/me/notification_prefs`.
- No subscription/billing/plan endpoint anywhere — `X-Subscription-Status` mechanism still has no data source.
- No case-timeline endpoint (BR-017) — and now no case-notes endpoint either (removed this update).
- No document-versions-list/restore endpoint (BR-024) despite `versionNumber` existing on the model.
- No AI entitlement/credit-preflight endpoint (BR-031), no classify/extract actions.
- No expenses module at all.
- No payment-reversal/compensating-transaction endpoint (BR-029) — and `DELETE` still exists on invoices/payments, still contradicting BR-028/029.
- Hard `DELETE` still present on cases, clients, documents, courts, opponents, invoices, payments, tenants, users, calendar events — still contradicts BR-016/024/028/029 for the entities those rules cover.
- `tenantId` still client-suppliable on `POST/PATCH /users`, and now also on `POST/PATCH /cases` — still contradicts BR-003.
- No error-envelope example anywhere in any of the 87 requests.
- `auth/signup` still exists, still contradicts BR-001.
- `public/lawyers` marketplace directory still exists, still a BR-scope concern (unlike reviews/consultations, this one was NOT removed).

### New since this update
- Employee/staff-management module removed entirely — BRD §6.2.3 now has zero backing (regression from M1's already-imperfect version, not an improvement).
- Case note-taking capability removed entirely (both the `notes[]` field and the endpoint to add one).
- Case-to-employee assignment endpoint removed (`team[]` is now presumably populated some other way not visible in this collection — unclear how a mobile client would ever add someone to a case's team, since no endpoint exists for it).
