# HOQOOQ Backend v2 Compliance Audit

Audit date: 2026-08-12  
PRD source used: `HOQOOQ_PRD_v2.0.md` (the available v2 PRD)  
Backend source verified: `D:\hoqooq\Hoqooq\src`  
OpenAPI artifact verified: `D:\hoqooq\Hoqooq\swagger.json`

## 2026-08-14 backend cutover re-verification

This section supersedes the 2026-08-11 table below. The backend was replaced
by the v2 implementation in commits through `7a615c8`; the older rows remain
only as an audit trail.

### Verified fixed / no longer applicable

- **BV2-001 / BV2-002:** tenant staff no longer use the global Users surface.
  Generic user creation was removed; `/employees` is tenant-scoped and
  `/employees/onboard` derives the Firm from the authenticated actor.
- **BV2-003:** authorization now uses account type, explicit permission codes,
  Case grants, and activity assignments. Job classification does not grant
  Finance or other authority.
- **BV2-005â€“BV2-008:** Lawyer specializations, granular Case capability
  grants, Case-owned Client/Opponent snapshots, and read-only global
  Governorate -> Court -> Circuit endpoints now exist and are server-validated.
- **BV2-009 / BV2-010:** Service of Process and Client Meeting modules now
  expose create/list/detail/update/assignment/completion flows with v2 status
  enums.
- **BV2-012 / BV2-013:** invoice/expense Finance and the global subscription
  guard were removed. Case-payment recording, reversal, Case totals, and Firm
  summary endpoints replace them.
- **BV2-015:** public signup, marketplace routes, and AI/RAG were removed.

### Remaining blockers found in the updated source

| ID | Severity | Backend location / endpoint | Actual behavior | Mobile impact | Required backend change | Status |
|---|---|---|---|---|---|---|
| BV2-016 | High | `employees/dtos/employee-response.dto.ts`; `GET /api/employees*` | The response omits `accountType`, `jobClassification`, user status, phone, and effective permissions. Only legacy `position`, department, user id/name/email, and specialization IDs are returned. | Employee list/edit cannot faithfully display or edit the authoritative professional classification/status model. Lawyer filtering cannot be derived safely from this DTO. | Return professional classification, account/status metadata, and effective permission data (or a documented companion representation). | Open |
| BV2-017 | High | `employees/dtos/update-employee.dto.ts`; `PATCH/DELETE /api/employees/:id` | Update cannot change full name, email, phone, or job classification; DELETE only deactivates and there is no Firm Admin reactivation endpoint. | Phase 3 employee lifecycle is only partial. | Add audited profile/classification update and activate/deactivate endpoints with tenant scope. | Open |
| BV2-018 | High | `cases/controllers/cases.controller.ts`; `/api/cases/:id/access-grants/:userId` | Capability sets can be replaced/revoked, but no endpoint lists the current Case grants and grantees. | “Case -> Access & Assignments” cannot display existing access or edit it safely. | Add a permission-protected, tenant-scoped Case-grant listing endpoint with employee summaries. | Open |
| BV2-019 | High | `infrastructure/database/seeds/reference-data.ts`, `seed.ts` | All 27 Governorates are defined, but only two Courts are seeded and no Circuits are seeded. The seeder also inserts missing permissions but does not detect/remove stale catalog entries or provide `seed:verify`. | Hearing Court/Circuit selectors are not production-complete and Circuit selection is empty after a fresh seed. Case forms are no longer affected because Flutter sources Case Courts from Google Places and saves only `courtName`. | Seed the approved national Court/Circuit catalog and add an idempotent verification command for Hearing/reference workflows. | Open |
| BV2-020 | Medium | `employees/services/employees.service.ts#onboard`; invitation delivery | Onboarding returns no activation token and invitation delivery is environment-dependent. | Mobile can submit onboarding but cannot guarantee a usable Employee account without configured delivery. | Document/configure the production invitation channel and expose a safe resend/status workflow. | Open |
| BV2-021 | High | `cases/dtos/update-case.dto.ts`; `PATCH /api/cases/:id` | `UpdateCaseDto` explicitly omits `client` and `opponents`, and no separate snapshot-update endpoint exists. Case-owned party data is therefore immutable after creation. | Phase 5 cannot satisfy P5-T05 or provide complete Case editing; Flutter must keep existing party snapshots read-only. | Add capability-protected, tenant-scoped Client/Opponent snapshot update operations with validation, audit/timeline history, and tests proving Case A changes cannot affect Case B. | Open |
| BV2-022 | High | `cases/entities/case.entity.ts`; `cases/services/cases.service.ts#changeStatus`; `PATCH /api/cases/:id/status` | The backend exposes an extra `SUSPENDED` state and accepts any direct transition, including transitions out of `ARCHIVED`; only entry into `ACTIVE` has prerequisites. | Flutter can hide the extra state but cannot enforce the Phase 5 lifecycle or archive finality against direct API calls. | Align the enum with the approved v2 lifecycle or update the authoritative PRD, then enforce and test an explicit transition matrix server-side. | Open |

The mobile app must not compensate for BV2-016â€“BV2-020 by guessing job
classification, fabricating Case grants, or shipping hard-coded Court/Circuit
records. Case Court suggestions from Google Places are an explicit product
decision, not fabricated reference data; Hearings retain backend references.

The minimal Case Court contract change was implemented on 2026-08-15. Other
findings below remain source-backed; runtime migration execution was not
performed during this audit.

## 2026-08-20 re-verification against live source

Every row in the "Open violations" table below was re-read directly against
the current `D:\hoqooq\Hoqooq\src` (not re-derived from this document). Net
result: **15 of the 22 original findings are now resolved**, 1 is newly
partial, 3 are partially resolved, and **6 remain fully open**. The table
below is left as-is for audit-trail purposes; treat this section as the
authoritative current status.

### Newly confirmed resolved (2026-08-20)

| ID | Evidence |
|---|---|
| BV2-001 | `users/controllers/users.controller.ts` `findAll()`/`findOne()` now require `system.tenants.read` (Super-Admin-only). No tenant actor can reach the unscoped repository query anymore. |
| BV2-002 | No `POST /users` exists at all. Account creation moved to `employees.controller.ts#onboard`, which derives `tenantId` from the JWT, not the request body. |
| BV2-003 | `core/guards/permissions.guard.ts` (read in full) has no `FIRM_ADMIN`/`ACCOUNTANT` bypass; pure permission-set check, `SUPER_ADMIN` restricted to `system.*`/`platform.*`. |
| BV2-004 | `employees.service.ts#onboard` sources `tenantId` server-side from the authenticated caller and rejects `platform.*`/`system.*` in delegated permissions. |
| BV2-005 | `onboard()`/`update()` require ≥1 valid `CaseType` specialization when `jobClassification === LAWYER`, reject specializations on non-lawyers. |
| BV2-006 | `cases.controller.ts` has `PUT/DELETE :id/access-grants/:userId` on `CaseCapability` grants; `calendar.service.ts` scopes Employee queries by capability grant. |
| BV2-007 | `cases.service.ts#changeStatus` requires a `CaseClient` snapshot row before activation — confirms Case-owned snapshots, not a shared directory. |
| BV2-008 | `courts.controller.ts` is entirely read-only (`GET` only) — no tenant Court CRUD. |
| BV2-009 | `service-of-process.controller.ts` has create/list/detail/update/assign/complete; `DELETE :id` sets `status = CANCELLED`, not a hard delete. |
| BV2-010 | `meetings` module fully exists with create/list/detail/update/assign/complete/cancel; cancel retains the record. |
| BV2-012 | `finance` module is now a pure Case-payment ledger (`summary`, `cases/:id`, `POST payments`, `PATCH payments/:id/reverse`) — no invoices/expenses, no delete anywhere. |
| BV2-013 | `core.module.ts`'s `APP_GUARD` list no longer includes a subscription guard; `subscription.guard.ts` no longer exists in the repo. |
| BV2-014 | `hearings.service.ts#remove`/`tasks.service.ts#remove` now set `status = CANCELLED` instead of deleting. |
| BV2-015 | No `/auth/signup` route in `identity.controller.ts`; no `ai` module anywhere under `src/modules`; no `marketplace` reference anywhere in `src`. |

### Still open or newly partial (2026-08-20)

| ID | Status | Evidence |
|---|---|---|
| BV2-011 | Partially resolved | `calendar.service.ts#getTimeline` now merges Hearing + Service of Process + Meeting + Task (was Hearing/Task only), and scopes `EMPLOYEE` accounts by capability/assignment. Still open: that scoping only runs `if (user.accountType === 'EMPLOYEE')` — a `FIRM_ADMIN` with `calendar.read` still gets every tenant activity with no per-module filter. Matches `SKIPPED_PHASE_BACKEND_BLOCKERS.md` P9-B01. |
| BV2-016 | Still open | `employees/dtos/employee-response.dto.ts`: `EmployeeUserResponseDto` still only exposes `id`/`email`/`fullName` — no `accountType`, `jobClassification`, status, phone, or effective permissions. |
| BV2-017 | Partially resolved | `update-employee.dto.ts` still can't change name/email/phone/classification. But `employees.service.ts#remove` is now a real deactivation (blocks on open primary Cases/Tasks, revokes sessions/permissions/grants) rather than a dead end. Still no reactivation endpoint. |
| BV2-018 | Still open | `cases.controller.ts` has `PUT`/`DELETE :id/access-grants/:userId` but no `GET :id/access-grants` to list current grantees. |
| BV2-019 | Still open (source-level, not row-count verified) | `seed.ts`/`reference-data.ts` still show a single small embedded Court list with no visible separate Circuit-seeding block. Not independently re-counted against a live database this pass. |
| BV2-020 | Partially resolved | `core/services/invitation.service.ts` now issues a real hashed token + `nodemailer` delivery. But delivery failures are only logged (`this.logger.error`), never surfaced to the caller, and there's still no resend/status endpoint. |
| BV2-021 | Still open | `update-case.dto.ts`: `OmitType(CreateCaseDto, ['client', 'opponents', 'status'])` — party snapshots remain immutable after creation. |
| BV2-022 | Still open | `case.entity.ts` still has `SUSPENDED`; `cases.service.ts#changeStatus` only validates prerequisites when the target is `ACTIVE` — every other transition, including out of `ARCHIVED`, is accepted unchecked. |

## Open violations (superseded 2026-08-14 / 2026-08-20 — audit trail only, do not use for current status)

| ID | Severity | PRD rule | Backend location / endpoint | Current behavior | Required v2 behavior | Mobile impact | Security / tenant impact | Required backend change | Blocked? | Status |
|---|---|---|---|---|---|---|---|---|---|---|
| BV2-001 | Critical | BR-007, BR-032, BR-034 | `src/modules/users/controllers/users.controller.ts`, `services/users.service.ts`, `repositories/user.repository.ts`; `GET /api/users`, `GET /api/users/:id` | The controller passes no tenant context to `findAll()` or `findOne()`; the service/repository are therefore globally addressed. | Every tenant-owned user read must be scoped to the authenticated tenant; cross-tenant IDs must not disclose data. | The existing `/users` assignee/employee source is unsafe. Flutter filtering is defense in depth only. | Cross-tenant user disclosure and possible cross-tenant assignment. | Derive tenant from JWT in controller/service and apply it to every user query; add no-leak tests. | Partial | Open |
| BV2-002 | Critical | BR-003, BR-007, BR-032 | `src/modules/users/services/users.service.ts`; `POST /api/users` | `create()` persists `createUserDto.tenantId` and `createUserDto.isSuperAdmin` directly. | Firm Admin creation is Super-Admin-only; Employee creation is allowed for Super Admin (explicit target Firm) and authorized tenant actors (their own Firm). A caller must never choose platform privilege or an arbitrary tenant. | The current mobile flow remains unsafe until this endpoint derives/validates actor and target Firm server-side. | Cross-tenant account creation and platform privilege escalation. | Replace the generic endpoint with explicit Super-Admin and tenant employee-provisioning flows; reject `isSuperAdmin`, enforce target-Firm rules, and audit create/update actions. | Yes | Open |
| BV2-003 | High | BR-002, BR-004, BR-005, BR-008, BR-028 | `src/core/guards/permissions.guard.ts`; `src/modules/cases/services/cases.service.ts`; `employees/services/employees.service.ts` | `FIRM_ADMIN` receives hard-coded full tenant access; `ACCOUNTANT`/`position === ACCOUNTANT` receives finance/dashboard/report bypass; employee onboarding assigns legacy roles from `position`. | Exactly three account types; job classification grants no authority; Firm Admin actions require their assigned permissions. | Permission-safe shell, Firm Admin restrictions, and finance gating cannot rely on the backend. | Privilege escalation / over-broad finance and Case access. | Remove role/job-title bypasses; evaluate direct/base permissions and Case grants only. | Yes | Open |
| BV2-004 | High | BR-003, BR-005 | `src/modules/employees/controllers/employees.controller.ts`; `POST /api/employees/onboard` | Tenant-less Super Admin may onboard a normal Employee by supplying `dto.tenantId`, with no explicit target-Firm authorization or audit boundary. | Super Admin may create/update Employees only for an explicitly selected Firm; Firm Admin/authorized tenant actor may manage Employees only in their own Firm. | Mobile must use a dedicated, audited provision/update contract. | Cross-tenant account manipulation. | Enforce Super-Admin target-Firm selection, tenant-admin own-Firm scope, immutable platform privilege, and audited create/update actions. | Yes | Open |
| BV2-005 | High | BR-006, BR-014, BR-032 | `src/modules/cases/services/cases.service.ts#assignLawyer`; `CaseTeam`; Case/Hearing endpoints | Specialization is optional, not tied to `LAWYER`, and an employee with no specializations is deliberately treated as unrestricted. Hearing DTO has no assigned-lawyer field or validation. | Legal assignee must be LAWYER-classified with at least one matching Case Type specialization; backend rejects mismatches. | Compatible lawyer picker may be UX-only and Hearing lawyer assignment is absent. | Bypassing mobile permits invalid legal assignments. | Add account classification, require specializations for lawyers, reject absent/mismatched specialization, add Hearing legal-assignee contract. | Yes | Open |
| BV2-006 | High | BR-008, BR-009, BR-010, BR-011 | `src/modules/cases/entities/case-team.entity.ts`; `cases.service.ts`; activity services | Case access is one `CaseAccessLevel` enum (`FULL_ACCESS`, `READ_ONLY`, `UPLOAD_DOCUMENTS`, `ASSIGN_HEARING`). All team members can fetch full Case joins; no scoped activity-only context contract exists. | Explicit Case capability grants, separate activity assignment, and minimum context only. | Case access management, revocation, document/finance isolation, and activity-only UI are blocked. | Full Case/client/opponent/timeline disclosure to broadly assigned users. | Implement capability grants and activity-assignment access checks with scoped DTOs. | Yes | Open |
| BV2-007 | High | BR-012 | `src/modules/cases/entities/case.entity.ts`; `clients`, `opponents`, `case-opponent` modules; Case DTOs | `Case` requires reusable `clientId`; opponent is a reusable tenant record attached via a join table. | Client and Opponent are Case-owned snapshots, not shared firm directories. | v2 Case creation/detail cannot use the real API. | Cross-matter data coupling and incorrect record ownership. | Add Case Client/Case Opponent snapshot entities and APIs; stop requiring master IDs. | Yes | Open |
| BV2-008 | High | BR-017, BR-018 | `src/modules/courts/entities/court.entity.ts`, `controllers/courts.controller.ts`, `services/courts.service.ts`; `/api/courts*` | Courts carry `tenant_id`; Firm users can create/update/delete and import copies from a catalog. Governorates/circuits are not global normalized reference entities/endpoints. | Global seeded Governorate -> Court -> Circuit hierarchy, read-only for Firm users, with server validation. | Existing Court flow must be disabled; dependent Case/Hearing selectors are blocked. | Invalid hierarchy and tenant-controlled reference data. | Replace tenant Court CRUD/import with global reference data and dependent read APIs. | Yes | Open |
| BV2-009 | High | BR-021, BR-024, BR-025, BR-033 | `src/modules/service-of-process/*`; `/api/service-of-process` | A real module exists, but uses `PENDING` status, no schedule/assignee/result/attachment model, broad CaseTeam authorization, no calendar integration, and `remove()` hard-deletes. | First-class scheduled, assigned Case activity with prescribed statuses, result, attachments, calendar/notifications, and retained history. | Feature can only be partially built; do not present it as v2-complete. | Incomplete audit/history and over-broad access. | Align schema/statuses and add scoped authorization, attachments, calendar/notification integration, and retention. | Partial | Open |
| BV2-010 | High | BR-022, BR-024, BR-025 | Backend `src/modules`; `swagger.json` | No Client Meeting module, entity, controller, or OpenAPI path exists. | Case-bound scheduled meeting with assignee, status, outcome, calendar and notifications. | Client Meetings are a backend blocker. | Missing access-controlled activity/audit trail. | Implement module and privacy-safe calendar/notification integration. | Yes | Open |
| BV2-011 | High | BR-024, BR-025 | `src/modules/calendar/services/calendar.service.ts`; notifications module | Timeline merges only CalendarEvent, Hearing, and Task; Service of Process/Meetings are absent. Non-Firm-Admin scoping relies on CaseTeam and returns the full joined Case in Hearing/Task timeline items. Notifications have no access-revocation suppression/privacy policy. | Unified authorized events and non-leaking notification/deep-link context. | Calendar and notification v2 completion is blocked. | Indirect hidden Case data disclosure. | Add all v2 activities, capability/assignment filtering, scoped event DTOs, and notification revocation/privacy checks. | Yes | Open |
| BV2-012 | High | BR-027, BR-028, BR-029 | `src/modules/finance/*`; `/api/finance/invoices`, `/payments`, analytics | Finance derives totals from Invoices/Payments and Expenses. `PermissionsGuard` gives ACCOUNTANT unconditional finance access; invoice/payment removal uses hard delete. No Case payment ledger exists. | Case agreed fee and immutable/reversible payment records, aggregates from those records, explicit finance permissions only. | Invoice UI must remain outside active v2 navigation; Case-ledger Finance is blocked. | Finance privilege leak and destructive financial history. | Create Case payment ledger/aggregates and reversal process; remove accountant bypass; retain history. | Yes | Open |
| BV2-013 | High | BR-030, BR-031 | `src/core/guards/subscription.guard.ts`; global `APP_GUARD` registration in `src/core/core.module.ts` | Every authenticated tenant request except subscriptions is 402 unless status is ACTIVE and unexpired. | Subscription must not automatically block/read-only the entire workspace; Firm inactive is explicit operator state. | Existing mobile interceptor/blocking route is a v2 violation and backend prevents a compatible replacement. | Availability policy conflict. | Remove global payment-state blocking; make entitlement/Firm-status checks explicit and scoped. | Yes | Open |
| BV2-014 | Medium | BR-019, BR-020, BR-023, BR-033 | `hearings.service.ts`, `tasks.service.ts`; delete routes | Hearing and Task removal uses `remove()` (hard delete); Tasks allow optional Case scope. | Legal activities preserve historical records; legal Tasks are Case-scoped. | Keep delete controls out of v2 and treat Task scope as partial. | Loss of legal history/audit evidence. | Soft-archive/retain historical activities and enforce Case scope for legal tasks. | Partial | Open |
| BV2-015 | Medium | BR-001, BR-035 | `src/modules/identity/controllers/identity.controller.ts`; `src/modules/ai/ai.controller.ts`; Swagger paths | Public `/auth/signup` and public lawyer marketplace remain; AI routes remain exposed. | No public self-registration/product marketplace; AI/RAG must not be a v2 route/feature. | Ensure no mobile route invokes or exposes them. | Scope/attack-surface violation. | Remove or restrict obsolete public/AI routes for v2 deployment. | No | Open |

## Verified fixed / not a current blocker

| Item | Evidence | Status |
|---|---|---|
| Historical Client raw-SQL crash | `src/modules/clients/repositories/client.repository.ts` now scopes through TypeORM query-builder property paths and the earlier raw `EXISTS` query is absent. | Verified fixed in source |
| Service of Process existence | `service-of-process` module is registered in `src/app.module.ts` and published in Swagger. | Exists, but BV2-009 remains |

## Backend blockers for v2 mobile

- Account-type and permission model compatible with BR-002/004/008/028.
- Lawyer classification/specialization and safe legal assignment.
- Capability-level Case grants and activity-only context.
- Case-local Client/Opponent snapshots.
- Global Governorate/Court/Circuit reference hierarchy.
- Client Meetings.
- Complete Service of Process workflow.
- Privacy-safe unified calendar/notifications.
- Case fee/payment ledger.
- Subscription behavior compatible with BR-031.
