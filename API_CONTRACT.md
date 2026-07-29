# Hoqooq API Contract

**Source:** `hoqooq-postman-import.json` (97 requests, Postman Collection v2.1). Per project instructions, this file is the source of truth for all HTTP calls — the mobile app's `dio` client is configured from what's documented here, not from the spec's "Assumed API contract" (spec §8) or the BRD's illustrative rules.

**⚠️ Read `CLAUDE.md` → "Critical: spec/collection divergence" before using this file.** The collection does not resemble the BRD's tenant-isolated, invite-only, no-hard-delete v1 product. It reads like a generic multi-tenant legal-SaaS boilerplate (public signup, lawyer marketplace, reviews, consultations, hard deletes everywhere, no MFA/subscription/tenant-isolation surface at all). Endpoint shapes below are documented exactly as given — do not assume they satisfy the BR-### rules just because they're listed.

**Base URL:** collection variable `baseUrl = "/"` — not a real host. No dev/staging/prod URLs are defined anywhere in the collection. **Needs user input.**

**Auth scheme observed:** `Authorization: Bearer <token>` on 90/97 requests. Login/signup/refresh/forgot-password/reset-password/`settings/public`/`reviews/lawyer/{id}` require no auth. No collection-level pre-request script rotates tokens — rotation logic is not visible in the collection itself, only inferable from `/auth/refresh`'s shape.

**Naming convention:** all JSON is **camelCase** (`accessToken`, `firstName`, `caseId`), not the snake_case the spec guessed (`access_token`, `case_number`). Freezed models must use `@JsonKey`/camelCase mapping accordingly.

---

## 1. Auth

| Method | Path | Auth | Request body | Response | Spec/BR mapping |
|---|---|---|---|---|---|
| POST | `/auth/login` | none | `{ email, password }` | 200 `{ accessToken, refreshToken, user }`; 401 on bad creds | Spec §4.1. **Diverges:** no `mfa_required`, no `permissions[]`, no `firm`, no `subscription_status` in the payload — `user` is an opaque object (shape not shown in examples for this endpoint, but matches `/users/me` shape elsewhere: id, email, firstName, lastName, isActive, roles[], tenant). BR-033 (session model) partially supported — see gap notes below. |
| POST | `/auth/signup` | none | `{ email, password, firstName, lastName, userType: LAWYER, firmName }` | 201 `{ accessToken, refreshToken, user }`; 409 email exists | **Not in spec at all. Directly contradicts BR-001** ("no public signup — invite-only"). `userType`/`firmName` fields imply this creates a tenant + owner in one self-service call. |
| POST | `/auth/refresh` | none | `{ refreshToken }` | 200 `{ accessToken, refreshToken, user }`; 401 invalid/expired | Spec §4.3 / BR-033. Shape matches rotation (new refreshToken returned), consistent with "15 min access / 7 day rotating refresh" — but the collection has no field confirming token lifetimes; those numbers come only from the BRD (§6.1.3), not from any response. |
| POST | `/auth/logout` | bearer | `{ refreshToken }` | 204; 401 | Spec §4.5, minus device-token revocation (no `/devices` endpoint exists at all — see gaps). |
| POST | `/auth/forgot-password` | none | `{ email }` | 200 (no body) | Spec §5.1 "Forgot password". |
| POST | `/auth/reset-password` | none | `{ token, newPassword }` | 204 | Not explicitly in spec screens but consistent with forgot-password flow. |
| POST | `/auth/change-password` | bearer | `{ oldPassword, newPassword }` | 204 | Not in spec; needed for Profile & Settings (§5.14). |

**Not present anywhere in the collection:** `/auth/mfa/verify`, `/auth/activate` (invite-token activation). BRD §6.1.3 states MFA is **mandatory** for Super Admin and Firm Admin, and the spec's entire §4.2 invitation-activation flow assumes an activate-by-token endpoint. **Neither exists in this collection.** See gap analysis.

---

## 2. Users / Roles / Permissions

| Method | Path | Auth | Request body | Response | Notes |
|---|---|---|---|---|---|
| POST | `/users` | bearer | `{ email, password, firstName, lastName, phone?, tenantId, roleIds[] }` | 201 User (id, email, firstName, lastName, isActive, createdAt, updatedAt, phone?, avatarUrl?, lastLoginAt?, roles[] w/ nested permissions[], tenant{id,name}) | **`tenantId` is client-supplied in the request body.** This directly conflicts with BR-003 ("the app never sends a tenant_id from the client — the backend derives it") and with spec line "the app never sends a tenant_id from the client." Flag before wiring this up. |
| GET | `/users` | bearer | — | 200 User[] | No pagination/query params shown (spec assumed `?page=&limit=`). |
| GET | `/users/me` | bearer | — | 200 User | This is the closest match to spec's `GET /me`, but **no `permissions: string[]` flat array, no `firm.timezone`, no `subscription_status`.** Permissions only appear nested inside each role's `permissions[]` (objects: `{id, resource, action, displayNameEn, displayNameAr}`), so RBAC code (`hasPerm()`) needs a different derivation than the spec's flat-array assumption. |
| GET | `/users/{id}` | bearer | — | 200 User | |
| PATCH | `/users/{id}` | bearer | `{ email?, firstName?, lastName?, phone?, tenantId?, roleIds[]? }` | 200 User | Same `tenantId`-in-body concern as POST. |
| DELETE | `/users/{id}` | bearer | — | 200 (empty) | **Hard delete of a user record** — no BRD rule explicitly forbids deleting users (BR-006 says offboarding = deactivate, never delete), so this is a likely spec violation if wired up naively. |
| GET | `/roles` | bearer | — | 200 (no example body) | "Get all roles with AR/EN translations for Firm Admins to assign" — matches BRD §6.2.2 role management, BR-004. |
| GET | `/roles/permissions` | bearer | — | 200 (no example body) | "Get all available permissions (Bilingual)". |

---

## 3. Public

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/public/lawyers` | **bearer** (despite name "public") | "Public directory of all Law Firms and Lawyers." **Not in spec/BRD — BRD §1.2 explicitly lists "public marketplace, lawyer discovery" as OUT OF SCOPE / future.** |
| GET | `/public/lawyers/specializations` | bearer | Same concern. |
| GET | `/settings/public` | none | `[{id, key, value, isPublic, createdAt, updatedAt, description?}]` — generic key/value settings, no defined keys. |

---

## 4. Tenants (Firms)

| Method | Path | Auth | Request | Response | Notes |
|---|---|---|---|---|---|
| GET | `/tenants/my-firm` | bearer | — | 200 (no example) | Closest match to spec's `firm` object in `/me`. |
| PATCH | `/tenants/my-firm` | bearer | `{ name?, address?, publicContactEmail?, publicContactPhone?, website?, specializations[]? }` | 200 | `specializations[]` / `website` / marketplace-style fields not in BRD's tenant/firm data dictionary (§8.2) at all. |
| POST | `/tenants/my-firm/logo` | bearer | multipart (fields not detailed in collection) | 200 | Matches BRD "Firm Admin adds firm name & image." |
| GET | `/tenants` | bearer | — | 200 (no example) | "Get all firms on the platform (System Admin)" — a **Super-Admin-only, cross-tenant** endpoint sitting in the same flat collection as firm-scoped ones, with no distinguishing base URL or auth scope. The mobile app (firm users only, per spec line 5) must never call this. |
| GET/PATCH/DELETE | `/tenants/{id}` | bearer | — | — | Same System-Admin-only concern. **DELETE hard-deletes a firm** — contradicts BR-013 (retention window, no abrupt deletion). |

---

## 5. Notifications

| Method | Path | Auth | Response |
|---|---|---|---|
| GET | `/notifications/me` | bearer | `[{id, userId, title, message, isRead, type: SYSTEM_ALERT\|INVOICE_DUE\|..., createdAt}]` |
| PATCH | `/notifications/{id}/read` | bearer | 200 Notification |

**Gap:** no `PATCH /me/notification_prefs` (spec §5.13 preferences screen) and no `/devices` register/unregister for FCM tokens anywhere in the collection.

---

## 6. Clients

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/clients` | bearer | `{ type: INDIVIDUAL\|COMPANY, name, email?, phone?, address?, taxId? }` | 201 Client |
| GET | `/clients` | bearer | — | 200 Client[] |
| GET/PATCH/DELETE | `/clients/{id}` | bearer | (PATCH: same fields, all optional) | 200 / 200 / 204 |

Shape is far simpler than BRD §8.3 `clients` (no `client_code`, no `national_id`/`commercial_reg`, no multi-email/phone arrays with "primary" flag, no duplicate-detection response). **DELETE is a hard delete** — BRD only describes "Archive (soft delete)," no physical delete from any client (spec §5.4).

---

## 7. Opponents

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST `/opponents` / GET `/opponents` / GET,PATCH,DELETE `/opponents/{id}` | bearer | `{ type: INDIVIDUAL\|COMPANY, name, email?, phone?, address?, notes? }` | Opponent object (id, type, name, createdAt, updatedAt, email, phone, address, notes) |

No `representative_name`/`representative_contact` fields (BRD §8.3 `opponents`), no case-association/conflict-check endpoint.

---

## 8. Employees (Staff)

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/employees/onboard` | bearer | `{ email, password, firstName, lastName, roleIds[], position, hireDate, phone?, department }` | 201 `{id, userId, position, hireDate, department, createdAt, updatedAt, user:{id,email,firstName,lastName}}` |
| GET | `/employees` | bearer | query: `position`, `department` | 200 Employee[] |
| GET/PATCH/DELETE | `/employees/{id}` | bearer | — | Employee |

**`position` enum:** `MANAGING_PARTNER, PARTNER, SENIOR_ASSOCIATE, ASSOCIATE, JUNIOR_LAWYER, PARALEGAL, LEGAL_ASSISTANT, LEGAL_RESEARCHER, SECRETARY, ACCOUNTANT, HR_MANAGER, IT_SUPPORT, GENERAL_MANAGER`.
**`department` enum:** `LITIGATION, CORPORATE, REAL_ESTATE, INTELLECTUAL_PROPERTY, FAMILY_LAW, CRIMINAL_LAW, FINANCE, HR, ADMINISTRATION, GENERAL`.

**Neither enum resembles the BRD's 5 firm roles** (Firm Admin, Lawyer, Legal Secretary, Legal Assistant, Accountant — BRD §3, §9). This looks like generic law-firm-HR modeling bolted onto a different role system than the one the RBAC matrix (spec §6, BRD §9) is built around. Also: `POST /employees/onboard` creates a password directly rather than an invite-token flow, contradicting BR-002/BR-006 (Firm Admin creates a user who then *activates* via one-time link — no plaintext password should transit from the creator).

---

## 9. Courts

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST/GET `/courts`, GET/PATCH/DELETE `/courts/{id}` | bearer | `{ name, type: SUPREME\|FIRST_INSTANCE\|APPEAL\|..., location?, contactInfo? }` | Court object |

**Gap:** no `court_circuits` endpoints at all (spec §5.8, BRD §8.4 `court_circuits` is a documented entity). `type` enum (SUPREME/FIRST_INSTANCE/APPEAL) differs from BRD's free-text `type` (e.g. "civil, criminal, commercial" — BRD §8.4 `courts`). **DELETE is a hard delete** — BRD §6.2.8 says "Deactivate rather than delete when referenced."

---

## 10. Cases

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/cases` | bearer | `{ title, caseNumber, type: FAMILY\|CIVIL\|COMMERCIAL\|LABOR\|..., clientId, filingDate?, status?, courtId?, description? }` | 201 Case incl. nested `client`, `court`, `assignments[]`, `notes[]` |
| GET | `/cases` | bearer | — | 200 Case[] (same nested shape) |
| GET/PATCH/DELETE | `/cases/{id}` | bearer | (PATCH same fields) | Case / Case / 204 |
| POST | `/cases/{id}/assignments` | bearer | `{ employeeId, role: LEAD\|SUPPORT }` | 201 Assignment `{id, role, employee:{...}}` |
| POST | `/cases/{id}/notes` | bearer | `{ content }` | 201 `{id, content, createdAt}` |

**Major gaps vs spec/BRD:**
- No `primary_lawyer_id`, no `priority`, no `agreed_fee` field anywhere on Case.
- No case lifecycle actions (`/activate`, `/close`) — only a generic `status` field on PATCH, with no visible transition guard.
- **No `GET /cases/{id}/timeline`** — BR-017 requires an immutable append-only timeline; nothing in this collection returns or writes timeline events. `case_timeline_events` (BRD §8.4) has no corresponding endpoint.
- `assignments[].role` is `LEAD`/`SUPPORT`, not the BRD's `PRIMARY_LAWYER, LAWYER, SECRETARY, ASSISTANT` (§8.4 `case_team`).
- **DELETE is a hard delete of a case** — directly contradicts BR-016 ("Cases are never physically deleted through normal operations... physical deletion is a Super-Admin-only, dual-approved, logged event").
- `case_number` is **client-supplied** in the POST body, not backend-generated (BRD says `CASE-YYYY-#####` format, doesn't specify who generates it, but spec assumed backend-generated numbering).

---

## 11. Tasks

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST/GET `/tasks`, GET/PATCH/DELETE `/tasks/{id}` | bearer | `{ title, description?, status: TODO\|IN_PROGRESS\|DONE, priority: LOW\|MEDIUM\|HIGH\|URGENT, dueDate?, caseId?, assignedTo? }` | Task object |

`status` enum (`TODO/IN_PROGRESS/DONE`) differs from BRD's `NEW → IN_PROGRESS → WAITING → COMPLETED → CANCELLED` (§8.7 `tasks`, §6.2.11). No `entity_type`/generic entity linking — only `caseId`. DELETE is a hard delete (spec doesn't explicitly forbid task deletion, lower risk here).

---

## 12. Documents

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/documents/upload` | bearer | multipart: `file` (required), `caseId` (text) | 201 `{id, name, contentType, size, createdAt, updatedAt, caseId}` |
| GET | `/documents/{id}/download` | bearer | — | 200 (binary/stream, no example) |
| DELETE | `/documents/{id}` | bearer | — | 204 |
| GET | `/documents` | bearer | — | 200 Document[] |

**Major gaps:** no `category_id` (BR mandates a category from firm lookups — BRD §6.2.9), no `access_level`, no `entity_type`/polymorphic linking beyond `caseId` (spec allows case/client/hearing/user), **no versioning endpoints at all** (`GET .../versions`, `.../versions/{v}/restore` — BR-024 requires full version history + admin restore), no signed-URL download (spec's `download-url` with short TTL vs. this collection's direct `download` — re-check whether this streams through the backend or redirects, since BR-025 access control depends on that). **DELETE is a hard delete** — BR-024 says documents are not hard-deleted by standard users.

---

## 13. Hearings

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST/GET `/hearings`, GET/PATCH/DELETE `/hearings/{id}` | bearer | `{ caseId, courtId, date, status: SCHEDULED\|COMPLETED\|POSTPONED\|..., notes? }` | Hearing object |

No `circuit_id`, `hearing_type_id`, `judge_name`, `outcome_text` (≥50 chars per BR-020), `next_hearing_at`, no separate `/complete` action, no conflict-detection response. `status` includes `POSTPONED` rather than BRD's `ADJOURNED`. **DELETE is a hard delete** — BR-020 says completed hearings "remain permanently associated with their case," implying no deletion once meaningful.

---

## 14. Finance

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST/GET `/finance/invoices`, GET/PATCH/DELETE `/finance/invoices/{id}` | bearer | `{ clientId, amount, issueDate, dueDate, caseId?, status: DRAFT\|ISSUED\|PAID\|CANCELLED, notes? }` | Invoice incl. nested `payments[]` |
| POST/GET `/finance/payments`, GET/DELETE `/finance/payments/{id}` | bearer | `{ invoiceId, amount, paymentDate, method: CASH\|BANK_TRANSFER\|CARD\|CHEQUE\|ONLINE, referenceNumber? }` | Payment object |

**Critical conflicts with BRD Finance rules:**
- **`DELETE /finance/invoices/{id}` and `DELETE /finance/payments/{id}` both exist** — BR-028 ("payment... is immutable after recording") and BR-029 ("financial records are never physically deleted... corrections are compensating transactions") are directly violated by having a delete endpoint at all.
- No reversal/compensating-transaction endpoint (spec assumed `POST /payments/{id}/reverse`).
- `amount` is a flat number on Invoice with no line items (BRD §8.6 `invoice_line_items`, spec's `InvoiceLineItem` model) — no line-item endpoints exist.
- No `agreed_fee`/case-fee paid-vs-remaining exposed on Case or via a dedicated endpoint (BR-026).
- No expenses endpoints at all (`GET/POST /expenses` assumed by spec; BRD §6.2.12 "Expenses" feature) — **entirely missing from the collection.**

---

## 15. Calendar

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST/GET `/calendar`, GET/PATCH/DELETE `/calendar/{id}` | bearer | `{ title, startTime, endTime, type: CUSTOM\|MEETING\|DEADLINE\|..., userId, description?, caseId? }` | Event object |
| GET | `/calendar/timeline` | bearer | query: `startDate, endDate, caseId, userId` | 200 (no example body) |

Generic single `calendar_events` model, not the spec's "hearings ∪ appointments ∪ task due dates ∪ reminders" composite (§5.7) — `/calendar` here appears to be its own event type rather than an aggregation of Hearing/Task/reminder records, while `/calendar/timeline` might be the aggregation endpoint (name suggests it) but has no documented response shape.

---

## 16. Reports & Dashboard

| Method | Path | Auth | Response |
|---|---|---|---|
| GET | `/reports/dashboard` | bearer | `{totalActiveCases, pendingTasks, upcomingHearings}` |
| GET | `/reports/export/cases` | bearer | 200 (CSV, no example) |
| GET | `/reports/export/clients` | bearer | 200 (CSV, no example) |
| GET | `/dashboard` | bearer | `{totalCases, activeCases, pendingTasks, upcomingHearings, totalInvoices, unpaidInvoices, recentActivity[]}` |

**Two separate, overlapping dashboard-metrics endpoints** (`/reports/dashboard` and `/dashboard`) with different shapes — needs clarification on which one the mobile Dashboard screen (spec §5.2) should call. Neither returns "today's hearings list," "top 3 notifications," or the finance-gated "Revenue widget" the spec's Dashboard screen needs — those will require assembling calls to `/hearings`, `/notifications/me`, and finance endpoints client-side, or asking the backend team to extend this response.

---

## 17. Settings

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| GET | `/settings/public` | none | — | Setting[] (key/value) |
| POST/GET `/settings`, PATCH/DELETE `/settings/{key}` | bearer | `{ key, value, description?, isPublic }` | Setting object |

Generic key-value store — none of the specific lookups the spec/BRD need (case types, hearing types, document categories, expense categories — BRD §8.7 `lookups`) have dedicated typed endpoints; they'd have to be encoded as opaque settings values, which loses the `label_en`/`label_ar` bilingual structure BR requires for lookups.

---

## 18. AI Assistant

| Method | Path | Auth | Request/Response |
|---|---|---|---|
| POST | `/ai/summarize` | bearer | No example body/response in collection. "Summarize a legal document using AI." |
| POST | `/ai/research` | bearer | No example. "Perform legal research using AI." Not in spec at all (spec has "research" as an AI Assistant document action per BRD §6.2.13, but no dedicated `/ai/research` endpoint was assumed). |
| POST | `/ai/chat` | bearer | No example. "Chat with AI Legal Assistant." |

**Critical gaps:** No `GET /ai/entitlement` (BR-031 credit metering preflight — spec's whole preflight-before-firing-AI-action flow, §5.12, has nothing to call). No classify/extract endpoints (spec's "Suggest category" / "Extract parties/dates/amounts" document actions). No streaming/SSE indication on `/ai/chat`. No `sources[]` citation shape visible (BR-030 per-firm RAG isolation is supposed to surface as citations the app renders — can't confirm the response includes them since there's no example). **This entire module is underspecified in the collection relative to what BR-030/031/032 and spec §5.12 require** — needs a real example call against a running environment before building the AI screens.

---

## 19. Reviews & Consultations (not in spec or BRD scope)

| Method | Path | Auth | Request |
|---|---|---|---|
| POST | `/reviews` | bearer | `{ lawyerId, rating, comment?, caseId? }` — "Clients Only" per description |
| GET | `/reviews/lawyer/{lawyerId}` | none | — |
| POST | `/consultations` | bearer | `{ lawyerId, tenantId, type: OFFICE\|..., scheduledDate, duration, categoryId, notes? }` |

**These two modules describe a public lawyer-marketplace with client-submitted reviews and consultation booking.** BRD §1.2 "Out of scope (future versions)" explicitly lists "Public marketplace, lawyer discovery, and consultation booking" and BRD §11 "Future Scope" repeats it. The mobile app per spec line 6 serves **firm users only** — clients never log in (BR-007). There is no scenario in v1 where this Flutter app calls these two modules. Flagged for exclusion, not implementation.

---

## Gap Analysis Summary

### Spec/BRD features with NO matching endpoint in the collection
- MFA verification (`/auth/mfa/verify`) — BRD §6.1.3 says mandatory for Super Admin/Firm Admin.
- Invite-token account activation (`/auth/activate`) — BR-002, spec §4.2.
- Device registration for push (`POST /devices`, `DELETE /devices/{id}`) — spec §11, BRD mobile push requirement.
- `PATCH /me/notification_prefs` — spec §5.13.
- Case timeline (`GET /cases/{id}/timeline`) — BR-017, a hard invariant.
- Case lifecycle actions (`/activate`, `/close`) beyond a raw `status` field — BR-015.
- Court circuits (`court_circuits` entity/endpoints) — BRD §8.4.
- Document versioning + restore — BR-024.
- Document category/access-level/entity-type richness — BR-023, BR-025.
- Hearing completion action with outcome/minutes — BR-020.
- Expenses (entire module) — BRD §6.2.12.
- Payment reversal/compensating transaction — BR-029.
- Case fee (agreed fee / paid / remaining) visibility — BR-026.
- AI entitlement/credit preflight — BR-031.
- AI classify/extract document actions — spec §5.12.
- Any subscription/billing/plan endpoint — BR-009 through BR-013. **No way to read `subscription_status` from anywhere**, so the entire read-only-mode mechanism (BR-010, BR-012) the spec's `ReadOnlyGuard` depends on has no data source in this collection.
- Any `X-Subscription-Status` response header, or tenant-scoping guarantee visible in any response.

### Collection endpoints the spec/BRD did not anticipate
- `POST /auth/signup` (public self-signup) — contradicts BR-001.
- `GET /public/lawyers`, `GET /public/lawyers/specializations` — contradicts marketplace out-of-scope decision.
- `GET/PATCH/DELETE /tenants`, `/tenants/{id}` (cross-tenant Super Admin operations mixed into the same flat collection).
- `POST /reviews`, `GET /reviews/lawyer/{id}`, `POST /consultations` — marketplace features, explicitly out of scope.
- `/employees` position/department taxonomy unrelated to the BRD's 5-role model.
- Generic `/settings` key-value store instead of typed lookups.
- Duplicate dashboard endpoints (`/dashboard` vs `/reports/dashboard`).
- Hard `DELETE` on cases, documents, invoices, payments, courts, tenants, users — BR-016, BR-024, BR-028/029 all forbid physical deletion of the entities they cover.
- Client-suppliable `tenantId` in `POST/PATCH /users` bodies — contradicts BR-003's core client-never-sends-tenant_id invariant.

I've documented every endpoint above exactly as the collection defines it so the contract is usable, but roughly a third of the entries above represent a direct conflict with a numbered BR rule, not just a missing nice-to-have. See `CLAUDE.md` for how this should change our approach before M1.
