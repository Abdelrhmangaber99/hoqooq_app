# HOQOOQ v2 Backend Completion Handoff

**Prepared:** 2026-08-17

**Audience:** Backend engineering and backend QA

**Release state:** **Blocked until the P0/P1 items and required release evidence below are closed**

## 1. Review basis and precedence

This handoff consolidates the remaining backend work after reviewing:

- `HOQOOQ_PRD_v2.0.md`, especially BR-001 through BR-035 and AC-001 through AC-022;
- the current backend source under `D:\hoqooq\Hoqooq`;
- backend `swagger.json`;
- `BACKEND_VIOLATIONS_V2.md` (using its 2026-08-14 cutover section, not the superseded historical table);
- `SKIPPED_PHASE_BACKEND_BLOCKERS.md`;
- `HOQOOQ_V2_PRODUCTION_READINESS_PLAN.md`; and
- the existing backend e2e specifications.

The backend snapshot reviewed was Git `7a615c8` plus visible local, uncommitted
changes in the backend working tree. Re-run the final verification after those
changes are committed and regenerate Swagger.

When requirements conflict, use this order:

1. BR-001 through BR-035 in the v2 BRD.
2. The v2 scope lock and acceptance criteria.
3. The functional requirements and data dictionary.
4. This document's endpoint suggestions, which are non-binding implementation
   guidance rather than a replacement for the BRD.

## 2. Important supersession note

Do **not** reopen the historical BV2-001 through BV2-015 findings as if they
still describe the current backend. The v2 cutover fixed their principal code
gaps: three account types, explicit permissions, granular Case capabilities,
Case-local parties, global reference endpoints, first-class activities,
Case-ledger Finance, removal of the global subscription guard, and removal of
public signup/marketplace/AI routes.

The remaining work is listed below. Some items require code/API changes; others
require integration, security, seed, or operational evidence.

## 3. P0 — release-blocking backend changes

### BE-01 — Complete the authoritative Employee administration contract

**BRD mapping:** BR-005, BR-006, BR-008, BR-032; AC-003 through AC-005.

**Existing tracking:** BV2-016, BV2-017, BV2-020.

**Current behavior**

- `EmployeeResponseDto` exposes legacy `position`/`department` and a nested
  user id/name/email, but omits authoritative `accountType`,
  `jobClassification`, user `status`, phone, and effective permissions.
- `UpdateEmployeeDto` cannot update full name, email, phone, or
  `jobClassification`.
- `DELETE /employees/:id` archives the Employee, deactivates the User, revokes
  permissions, Case grants, assignments, and sessions. There is no Firm Admin
  reactivation flow. Super Admin's `PATCH /users/:id/status` can reactivate the
  User row but does not restore the archived Employee profile or grants.
- Invitation email failure is logged and swallowed after the database commit.
  There is no invitation delivery status or resend endpoint.

**Required backend result**

- Return an authoritative Employee admin DTO containing Employee id, User id,
  account type, job classification, account status, name, email, phone,
  specializations, and effective/direct permission information as documented.
- Support tenant-scoped search/filter by name, classification,
  specialization, and status.
- Add audited profile/classification updates with LAWYER specialization
  validation.
- Define explicit activate/deactivate semantics. Do not make “reactivation” a
  partial User-row update while the Employee remains archived.
- Add invitation delivery state plus safe resend/renewal. Delivery failure must
  be observable and recoverable without direct database access.

**Suggested contract**

- `GET /employees?query=&jobClassification=&caseTypeId=&status=`
- `PATCH /employees/:id/profile`
- `PATCH /employees/:id/status` with `{status: ACTIVE|INACTIVE}`
- `POST /employees/:id/invitation/resend`
- Equivalent Super Admin operations must require an explicit target Firm and
  expose metadata only.

**Acceptance evidence**

- A LAWYER without a specialization is rejected.
- A non-LAWYER cannot retain lawyer specializations.
- Firm A cannot read/update/reactivate Firm B employees.
- Deactivation invalidates the next authenticated request.
- Reactivation produces a consistent, usable Employee account.
- Permission/profile/status changes are append-only audited.

### BE-02 — Complete Case access administration and activity-only context

**BRD mapping:** BR-008 through BR-011, BR-024, BR-032, BR-034; AC-009,
AC-010, AC-019, AC-020.

**Existing tracking:** BV2-018 and Phase 6/7 assignment blockers.

**Current behavior**

- Case capability grants can be replaced or revoked at
  `/cases/:id/access-grants/:userId`, but there is no endpoint that lists the
  current grantees and their active capabilities.
- The Employee contract cannot safely power a compatible-assignee picker.
- Activity assignment grants access to the activity, but there is no finalized
  shared response contract for the minimum safe Case context needed by an
  activity-only user.

**Required backend result**

- Add a tenant-scoped, capability-protected Case grant list containing safe
  Employee summaries and active capabilities.
- Recheck both base permission and Case capability on every Case subsection,
  document, finance, activity, calendar, notification, and deep-link request.
- Define a minimal activity-context DTO that does not expose Client, Opponent,
  Documents, Finance, or unrelated Case activity data.
- Revocation must apply on the next request and suppress later calendar and
  notification visibility.

**Suggested contract**

- `GET /cases/:caseId/access-grants`
- `GET /activities/:type/:id/context` or equivalent typed activity detail DTOs
  with explicitly documented safe fields.

**Acceptance evidence**

- Grant listing never crosses tenant boundaries.
- `document.upload` does not imply document download, Case edit, or Finance.
- Hearing-only assignment returns only that Hearing plus minimum Case context.
- Revoking the grant/assignment removes access immediately.
- Web and mobile tokens receive the same authorization decision.

### BE-03 — Enforce the approved Case lifecycle and legal-assignment rules

**BRD mapping:** BR-013 through BR-016, BR-033; AC-004, AC-005.

**Existing tracking:** BV2-022 plus Phase 5 lifecycle blockers.

**Current behavior**

- `CaseStatus` still includes `SUSPENDED`; the approved lifecycle is
  `DRAFT|ACTIVE|CLOSED|ARCHIVED`.
- `changeStatus` allows arbitrary transitions, including transitions out of
  `ARCHIVED`.
- activation currently requires `primaryLawyerId`, although BR-015 permits an
  active Case without a legal Lawyer assignment.
- changing only `caseTypeId` does not revalidate the existing primary Lawyer;
  it also does not resolve potentially incompatible Hearing legal assignees.
- changing status to `ARCHIVED` does not set `isArchived`, while the default
  list filters only `isArchived = false`. Archived Cases can therefore remain
  in the normal list. Primary-Lawyer retrieval also depends on
  `isArchived = false`, producing inconsistent archived access.

**Required backend result**

- Remove `SUSPENDED` from the active v2 contract or obtain an explicit BRD
  amendment.
- Enforce and test an explicit transition matrix with terminal archive
  behavior.
- Keep Lawyer assignment optional for Case activation; validate specialization
  whenever a Lawyer is assigned.
- On Case Type change, atomically revalidate all legal assignments and reject
  or require an explicit, audited resolution.
- Make archive filtering and authorized historical retrieval consistent.
- Preserve a timeline and audit record for every status transition.

**Acceptance evidence**

- Invalid direct API transitions fail.
- Archived Cases disappear from default active lists but remain retrievable by
  authorized users.
- A Case can activate without a Lawyer when all other required data is valid.
- A mismatching primary/Hearing Lawyer cannot survive a Case Type change.

### BE-04 — Add audited Case-local Client and Opponent updates

**BRD mapping:** BR-012, BR-033; AC-008.

**Existing tracking:** BV2-021.

**Current behavior**

Case-local Client/Opponent snapshots are created correctly, but
`UpdateCaseDto` omits them and no dedicated snapshot-update endpoints exist.

**Required backend result**

- Add `client.edit`/`opponent.edit` capability-protected update operations.
- Scope every query by authenticated tenant and Case.
- Store before/after audit evidence and a material Case timeline entry.
- Never propagate changes to another Case containing the same real person.

**Acceptance evidence**

- Updating Case A's party cannot alter or disclose Case B's party.
- Unauthorized and cross-tenant IDs return the finalized non-disclosing error.
- Normal history is preserved; no shared Client/Opponent master record is
  reintroduced.

### BE-05 — Close Calendar and notification authorization/generation gaps

**BRD mapping:** BR-024, BR-025, BR-032, BR-034; AC-010 through AC-013,
AC-019, AC-020.

**Current behavior**

- Employee timeline/feed queries are assignment/Case-capability scoped.
- Firm Admin timeline/feed queries become tenant-wide after `calendar.read`;
  they are not filtered by the relevant Hearing, Service, Meeting, or Task
  source permission.
- New-assignee notifications exist, but previous assignees are not reliably
  notified on reassignment.
- ordinary schedule updates do not consistently notify affected users.
- access grant/revoke effects do not have a complete notification contract.
- `GET /notifications/daily` computes an on-demand feed. It is not a
  duplicate-safe job creating user-specific persisted read/unread records.

**Required backend result**

- Apply the same source authorization to Calendar and daily feeds as to the
  underlying record for every account type.
- Generate safe, user-specific notifications for assignment, reassignment,
  material schedule changes, and access changes where the user's action or
  visibility is affected.
- Implement duplicate-safe daily notification production for assigned work.
- Keep revocation suppression and recheck authorization at notification open.
- Payloads must use minimal identifiers and never include hidden party,
  document, or finance information.

**Acceptance evidence**

- Firm Admin with `calendar.read` but without `hearing.view` does not receive
  Hearing rows.
- Reassignment notifies the new assignee and handles the previous assignee
  according to the finalized policy.
- A material schedule change creates one notification per affected user.
- Re-running the daily job does not create duplicates.
- Revoked users receive no future record notifications and cannot deep-link
  into the record.

### BE-06 — Make critical audit records durable and readable

**BRD mapping:** BR-003 through BR-005, BR-016, BR-019 through BR-030,
BR-033; AC-018.

**Current behavior**

- A global interceptor writes mutation audit rows after successful requests,
  but writes are best-effort and failures are swallowed.
- Generic records normally have `oldValue = null`; routes using parameter names
  such as `tenantId` or `userId` may not populate `resourceId`.
- Critical domain operations are not consistently audited transactionally.
- There is no tenant audit or platform audit read endpoint despite
  `audit.read` and `platform.audit.read` permissions.

**Required backend result**

- Create append-only audit records with actor, tenant, target, timestamp,
  action, request id, and before/after state where applicable.
- Critical mutation and its audit evidence must succeed/fail together, or use
  another durable delivery design with equivalent guarantees.
- Add permission-protected, paginated tenant and platform audit read APIs.
- Platform audit must expose platform operations only; Super Admin must not
  gain tenant legal-content access through audit payloads.
- No normal account may update or delete audit rows.

**Acceptance evidence**

- Provisioning, account status, permissions, Case grants/status, assignments,
  schedules, document upload/version/archive, payments/reversals,
  subscriptions, plans, and Firm status all produce attributable audit rows.
- Audit-write failure cannot silently report a critical mutation as fully
  successful.
- Tenant audit is tenant-scoped; platform audit contains no legal payload.

### BE-07 — Complete operator-controlled plans and subscriptions

**BRD mapping:** BR-030, BR-031; AC-017, AC-018.

**Current behavior**

- Plan API is public read-only `GET /subscriptions/plans` and returns active
  plans only. No route uses `platform.plan.manage`.
- A plan has name, prices, employee/storage limits, and active state, but no
  description; enabled modules are not represented if module entitlements are
  intended.
- Super Admin can activate to `ACTIVE`, deactivate to `CANCELLED`, or create a
  versioned plan/cycle change. There is no operator API to explicitly set
  `PENDING` or `EXPIRED`, set period dates, or inspect full subscription
  history.
- activation/cancellation mutate the current row, while plan/cycle changes
  create history versions. History semantics are therefore inconsistent.
- `GET /tenants` does not provide the complete BRD registry summary: Firm Admin
  metadata and employee count are absent, and no search/pagination contract is
  exposed.

**Required backend result**

- Add permission-protected plan create/edit/enable-disable/list-all operations.
- Add a Super Admin subscription operation that explicitly controls plan,
  billing cycle, period dates, and `PENDING|ACTIVE|EXPIRED|CANCELLED` status
  while retaining one current row plus immutable history.
- Add paginated subscription-history retrieval.
- Return a stable Firm registry/detail DTO containing Firm Admin metadata,
  current plan/subscription state, explicit Firm status, creation date, and
  employee count.
- Continue enforcing Firm `ACTIVE|INACTIVE` independently from subscription
  status.

**Important correction**

The v2 BRD is operator-controlled. It does **not** require an automatic dunning
state machine. The blocker is the missing operator API to set `EXPIRED` and
retain history—not a requirement to add an automatic workspace-blocking expiry
guard. The old global subscription guard must remain removed.

**Acceptance evidence**

- Super Admin can set a subscription to EXPIRED through the API.
- EXPIRED does not change Firm status and does not block the workspace.
- Explicit Firm INACTIVE does deny Firm authentication/subsequent requests.
- Every subscription/plan/status change retains history and audit evidence.
- Employee and Firm Admin accounts cannot call platform plan/subscription APIs.

## 4. P1 — required completeness changes

### BE-08 — Complete judicial reference seed data and verification

**BRD mapping:** BR-017, BR-018; AC-006, AC-007.

**Existing tracking:** BV2-019.

The current seed defines all Governorates but only two Courts and no Circuits.
Add the approved production Court/Circuit catalog with EN/AR labels and an
idempotent `seed:verify` command that detects missing, duplicate, stale, and
invalid relationships. Firm users must remain unable to create tenant Courts.

Required evidence:

- repeated seeds create no duplicates and do not overwrite credentials;
- every Court belongs to one Governorate;
- every Circuit belongs to one Court;
- invalid hierarchy fails verification; and
- a fresh database becomes usable without manual SQL.

### BE-09 — Expose authorized prior Document versions

**BRD mapping:** BR-026, BR-032, BR-033.

The backend stores immutable `document_versions`, but exposes only new-version
upload and current-file download. Add authorized version-list and specific
version-download operations. Apply the same tenant, Case, and document download
capabilities used for the current file. Archived metadata/history must remain
available according to retention policy without exposing the object key.

Required evidence:

- replacing a file leaves every prior version retrievable by an authorized
  user;
- Firm A cannot list/download Firm B versions;
- authorization is rechecked on every download; and
- storage keys remain bounded by tenant, Case, Document, and version.

### BE-10 — Complete activity history, Timeline production, and conflict rules

**BRD mapping:** BR-019 through BR-025, BR-033.

**Current gaps**

- Schedule updates overwrite current activity dates without consistently
  preserving previous schedule evidence.
- Case Timeline production is incomplete for Meeting, Task, Document, Payment,
  reassignment, reschedule, completion/cancellation, and other material events.
- Hearing creation checks only an exact-time Hearing conflict for the assigned
  Lawyer. It does not detect real overlaps across Hearing, Service, Meeting,
  and other time-bound assignments.
- Several activity models have only a point timestamp, so a true overlap rule
  needs a documented duration/end-time policy.

**Required backend result**

- Preserve old/new schedule, actor, reason, and timestamp on every reschedule.
- Produce complete, ordered, capability-safe Case Timeline events for material
  Case/activity/document/payment changes.
- Define start/end or default-duration semantics and a unified conflict check.
- Permit an override only with justification and durable audit evidence.

Required evidence includes concurrent boundary tests, reassignment visibility,
reschedule history, and Timeline ordering.

### BE-11 — Finalize platform registry metadata and Super Admin isolation

**BRD mapping:** BR-003, BR-004, BR-007, BR-032; AC-018.

The source-level Super Admin guard correctly rejects tenant legal-resource
permissions, but release requires a complete integration matrix proving that
the platform registry/detail APIs expose metadata only. Verify that Super Admin
cannot retrieve Case, party, activity substance, tenant Documents/downloads,
or Case Finance through direct IDs, filters, exports, audit, or object storage.

Also ensure status and permission-management endpoints cannot grant platform
permissions to Firm Admin or Employee accounts.

## 5. P2 — required release and operational evidence

These are not all API design changes, but production must remain blocked until
the evidence exists.

### BE-12 — Security and tenant-isolation suite

Provide authenticated tests across every tenant-owned resource for:

- Firm A versus Firm B list/detail/create/update/archive/download;
- cross-tenant Case grants and activity assignments;
- object IDs that do not disclose resource existence;
- authorization revocation on the next request;
- account and Firm INACTIVE behavior;
- Super Admin metadata-only isolation;
- Employee/Firm Admin denial of platform routes; and
- identical web/mobile API authorization.

### BE-13 — Finance reconciliation suite

The Case fee/payment ledger exists, but release evidence must cover zero and
negative payment rejection, overpayment policy, reversal exclusion, immutable
history, explicit Finance permissions, Firm totals derived from source
payments, and cross-tenant denial. ACCOUNTANT classification alone must grant
nothing.

### BE-14 — Seeder, migration, backup, restore, and rollback proof

Provide:

- `seed:verify` and repeated-seed idempotency results;
- empty-database bootstrap evidence;
- migration strategy for existing production data;
- rollback or backup strategy for destructive migrations;
- successful database restore rehearsal;
- successful document-store restore rehearsal; and
- a documented, rehearsed release rollback procedure.

### BE-15 — Production hardening evidence

Provide passing evidence for secret scanning, JWT/refresh behavior, login abuse
protection, malicious and oversized upload rejection, authorization/IDOR
penetration tests, list/search latency targets, structured error monitoring,
failed-notification monitoring, and the 99.5% availability target's operational
dependencies.

## 6. Required API and artifact handoff

For every API change above, deliver together:

- migration(s) with rollback/backup notes;
- DTO validation and stable response DTOs;
- permission and tenant-scope declarations;
- unit/integration/e2e tests;
- regenerated `swagger.json`;
- regenerated Postman/API artifacts if maintained;
- explicit error status/envelope examples; and
- a short mobile/web migration note for any changed field or route.

Do not return raw persistence entities when doing so would expose storage keys,
internal relations, tenant legal data, or unstable implementation fields.

## 7. Do-not-regress constraints

- Do not restore public signup, lawyer marketplace, or AI/RAG routes.
- Do not restore Invoice/Expense workflows; v2 Finance is Case fee + payments.
- Do not restore a subscription middleware that globally blocks or makes the
  workspace read-only when a subscription expires.
- Do not use job classification (LAWYER, ACCOUNTANT, etc.) as authorization.
- Do not give Firm Admin an unremovable full-access bypass.
- Do not reintroduce reusable cross-Case Client/Opponent master records into
  active v2 workflows.
- Do not allow tenant-created Governorates, Courts, or Circuits.
- Do not expose tenant legal/document/finance content to Super Admin.
- Do not treat client-side filtering or hidden buttons as authorization.
- Do not physically delete normal legal, financial, document, activity, audit,
  or subscription history.

## 8. Definition of backend-complete

The backend is ready for final web/mobile integration only when:

1. BE-01 through BE-11 are implemented and reviewed.
2. BE-12 through BE-15 evidence is attached to the release candidate.
3. BR-001 through BR-035 each map to at least one passing automated or formal
   acceptance test.
4. AC-001 through AC-022 pass in production-like staging.
5. Swagger and runtime behavior match exactly.
6. A fresh database can be migrated, seeded, verified, and used without manual
   SQL.
7. Backup/restore and rollback have been rehearsed.
8. No P0/P1 item in this handoff remains open.
