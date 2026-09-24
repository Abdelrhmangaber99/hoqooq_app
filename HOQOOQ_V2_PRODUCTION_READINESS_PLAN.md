# Hoqooq v2.0 — Production Readiness Implementation Plan

Backend-blocked phases intentionally skipped by the user are tracked in
[`SKIPPED_PHASE_BACKEND_BLOCKERS.md`](SKIPPED_PHASE_BACKEND_BLOCKERS.md),
including the small Flutter follow-up required after each backend fix.

**Project:** Hoqooq Legal Practice Management Platform  
**Target:** Production-ready Hoqooq v2.0  
**Primary references:** `HOQOOQ_PRD_v2.0.md` and `API_CONTRACT.md`  
**Scope:** Backend + API + Web + Flutter Mobile + Database + Seeder + QA + Security + DevOps

---

## 1. Authority and Implementation Rule

The authoritative order for implementation is:

1. `HOQOOQ_PRD_v2.0.md` Business Rules.
2. PRD v2.0 Scope Lock.
3. PRD Functional Requirements.
4. PRD Data Model and Permission Catalog.
5. Updated backend/API implementation.
6. Web and mobile client implementation.

When the current backend or API contract conflicts with the v2.0 PRD, the **v2.0 PRD wins**.

A feature is not considered complete merely because its UI works. A phase is complete only when:

- database/domain behavior is correct;
- server-side authorization is correct;
- tenant isolation is correct;
- API contract is correct;
- automated backend tests pass;
- web/mobile clients use the final contract;
- client tests pass;
- no known blocker for that phase remains.

---

# Phase 0 — Scope Freeze, Compliance Audit and Traceability

## Goal

Create a reliable migration baseline before changing production behavior.

## Tasks

- Build a complete BRD-to-code traceability matrix.
- Map every `BR-001` through `BR-035`.
- Map all PRD acceptance scenarios `AC-001` through `AC-022`.
- Inspect every current backend module and endpoint.
- Classify every endpoint/feature as:
  - `PASS`
  - `PARTIAL`
  - `FAIL`
  - `MISSING`
  - `REMOVE`
  - `DEFERRED`
- Identify all database migrations required.
- Identify deprecated v1/current behavior.
- Create rollout and rollback strategy.
- Create feature flags where phased deployment is required.
- Prepare isolated development, test and staging environments.
- Prepare Firm A / Firm B isolation fixtures.
- Establish production blocker registry.

## Known areas requiring migration

- `/users` tenant-scoping issue.
- Client read-path backend failure.
- Current authentication-role model versus three-account-type model.
- Shared Client/Opponent records versus case-local snapshots.
- Tenant-owned Courts versus global Governorate → Court → Circuit hierarchy.
- Broad CaseTeam access versus capability-based Case grants.
- Missing Client Meetings.
- Incomplete Service of Process.
- Invoice/expense-oriented Finance versus Case fee/payment ledger.
- Subscription middleware behavior conflicting with v2.
- AI endpoints that must not be exposed as v2 functionality.
- Public signup/marketplace functionality that is outside v2 scope.
- Missing/incomplete Timeline and Document versioning.
- Permission model mismatches.
- Staff-management security gaps.
- Super Admin legal-content privacy boundary.

## Deliverables

- `V2_COMPLIANCE_MATRIX.md`
- `BACKEND_V2_GAPS.md`
- `DB_MIGRATION_PLAN.md`
- `API_V2_MIGRATION_PLAN.md`
- `PRODUCTION_BLOCKERS.md`
- `TEST_TRACEABILITY_MATRIX.md`

## Phase 0 Tests

- [ ] **P0-T01** Every BR-001 through BR-035 has at least one planned automated or acceptance test.
- [ ] **P0-T02** Every current API endpoint is classified.
- [ ] **P0-T03** AI, marketplace, invoice and expense flows are not incorrectly counted as required v2 features.
- [ ] **P0-T04** Firm A and Firm B test tenants can be created independently.
- [ ] **P0-T05** Existing production data has a migration strategy.
- [ ] **P0-T06** Every destructive database migration has a rollback or backup strategy.
- [ ] **P0-T07** Production blockers are explicitly documented.

## Exit Gate

No major v2 implementation begins until the compliance matrix and blocker list are approved.

---

# Phase 1 — Production Seeder and Reference Data Foundation

## Goal

Create an idempotent, secure and production-safe seeding system before application behavior depends on seeded identities or reference data.

The seeder is a **production requirement**, not only a development convenience.

---

## 1.1 Seeder Responsibilities

The seeder must own only deterministic platform bootstrap/reference data.

### A. Bootstrap Super Admin

Seed exactly one bootstrap Super Admin.

Requirements:

- Exactly one bootstrap account.
- No duplicate Super Admin after repeated seed execution.
- Super Admin has no tenant.
- Credentials must come from environment/deployment secrets.
- No production password committed to the repository.
- Seeder must update safe metadata if required without recreating the account.
- Seeder must never create a second Super Admin because of email/name changes unless explicitly migrated.

Recommended environment variables:

```env
BOOTSTRAP_SUPER_ADMIN_EMAIL=
BOOTSTRAP_SUPER_ADMIN_PASSWORD=
BOOTSTRAP_SUPER_ADMIN_DISPLAY_NAME=
```

Never store real values in Git.

---

### B. Account Types

Seed or constrain the authentication account types to exactly:

```text
SUPER_ADMIN
FIRM_ADMIN
EMPLOYEE
```

Professional classifications must remain separate:

```text
LAWYER
SECRETARY
ACCOUNTANT
ASSISTANT
OTHER
```

---

### C. Permission Catalog

Seed the complete v2 permission catalog.

At minimum:

#### Platform Permissions

```text
platform.firm.create
platform.firm.read
platform.firm.status.manage
platform.firm_admin.permission.manage
platform.user.metadata.read
platform.user.status.manage
platform.plan.manage
platform.subscription.manage
platform.audit.read
```

#### Firm-Level Permissions

Seed the authoritative codes required by the finalized implementation, including families such as:

```text
firm.profile.read
firm.profile.manage

employee.read
employee.create
employee.edit
employee.permission.manage
employee.status.manage

case.create
case.read
case.edit
case.status.manage
case.access.manage

client.view
client.edit

opponent.view
opponent.edit

document.view
document.download
document.upload
document.edit
document.manage

hearing.view
hearing.create
hearing.edit
hearing.assign
hearing.complete

service.view
service.create
service.edit
service.assign
service.complete

meeting.view
meeting.create
meeting.edit
meeting.assign
meeting.complete

task.view
task.create
task.assign
task.update
task.complete

calendar.read
calendar.manage

finance.case.view
finance.payment.record
finance.manage
finance.firm.read

report.operational.read
report.finance.read
report.export

audit.read
```

Final codes must exactly match the implemented authorization engine and API contract.

---

### D. Case Types

Seed global Case Types:

```text
CRIMINAL
CIVIL
COMMERCIAL
FAMILY
LABOR
ADMINISTRATIVE
OTHER
```

Each must include:

- stable code;
- English label;
- Arabic label;
- active flag.

Seeder must preserve stable IDs or stable unique codes across environments where required.

---

### E. Egypt Governorates

Seed all supported Egyptian Governorates.

Each Governorate must have:

- stable code;
- Arabic name;
- English name;
- active flag.

---

### F. Courts

Seed global Courts.

Each Court must:

- belong to exactly one Governorate;
- have stable identifier/code;
- include Arabic/English labels where available;
- contain type/address metadata required by product;
- be global, not tenant-owned.

---

### G. Court Circuits

Seed Court Circuits.

Each Circuit must:

- belong to exactly one Court;
- have stable identifier/code;
- include localized labels;
- not be tenant-owned.

---

### H. Optional Initial Subscription Plans

If the production release will ship with predefined plans, seed only operator-approved plans.

Example fields:

```text
name
description
priceMonthly
priceYearly
maxEmployees
storageLimit
isActive
```

Plans must be safely upserted by a stable business key.

Do not overwrite operator-edited commercial values on every application boot unless that behavior is explicitly intended.

---

## 1.2 Seeder Architecture

Recommended structure:

```text
seed/
├── seed.ts
├── bootstrap/
│   └── super-admin.seed.ts
├── permissions/
│   └── permissions.seed.ts
├── legal-reference/
│   ├── case-types.seed.ts
│   ├── governorates.seed.ts
│   ├── courts.seed.ts
│   └── circuits.seed.ts
├── subscriptions/
│   └── plans.seed.ts
└── helpers/
    ├── upsert.helper.ts
    └── seed-lock.helper.ts
```

---

## 1.3 Seeder Safety Requirements

- Idempotent.
- Transactional where practical.
- Safe to rerun.
- Deterministic.
- Uses unique business keys.
- Does not duplicate reference data.
- Does not silently delete operator-created production records.
- Does not reset passwords on every start.
- Does not automatically grant hidden permissions.
- Does not create tenant business data.
- Logs what was created/updated/skipped.
- Fails loudly on malformed reference relationships.
- Supports CI/test database execution.
- Supports staging execution.
- Supports controlled production execution.
- Prefer explicit seed command over automatic destructive startup behavior.

Example:

```bash
npm run seed
npm run seed:verify
```

---

## Phase 1 Tests — Seeder

- [ ] **P1-T01** Run seeder twice → exactly one bootstrap Super Admin remains.
- [ ] **P1-T02** Run seeder 10 times → no duplicate Case Types.
- [ ] **P1-T03** Run seeder 10 times → no duplicate Governorates.
- [ ] **P1-T04** Run seeder 10 times → no duplicate Courts.
- [ ] **P1-T05** Run seeder 10 times → no duplicate Circuits.
- [ ] **P1-T06** Every Court references a valid Governorate.
- [ ] **P1-T07** Every Circuit references a valid Court.
- [ ] **P1-T08** Every active Case Type has EN + AR labels.
- [ ] **P1-T09** Bootstrap Super Admin has `tenantId = null`.
- [ ] **P1-T10** No production bootstrap password exists in source control.
- [ ] **P1-T11** Seeder cannot create a second Super Admin accidentally.
- [ ] **P1-T12** Seeder does not assign job classifications as authentication account types.
- [ ] **P1-T13** Permission codes are unique.
- [ ] **P1-T14** Seeder permission catalog exactly matches the finalized backend authorization catalog.
- [ ] **P1-T15** Invalid Court → Governorate relationship causes seed verification failure.
- [ ] **P1-T16** Invalid Circuit → Court relationship causes seed verification failure.
- [ ] **P1-T17** Seeder does not overwrite production user passwords on rerun.
- [ ] **P1-T18** Seeder can execute against an empty database from scratch.
- [ ] **P1-T19** Seeder verification command detects missing required reference data.
- [ ] **P1-T20** No tenant-owned Case, Client, Document, Hearing, Task or Payment business records are created by production seed.

## Exit Gate

The application can bootstrap an empty database into a valid platform state without manual SQL.

---

# Phase 2 — Critical Security and Tenant Isolation

## Goal

Eliminate all known cross-tenant exposure before external testing.

## Tasks

Server-side tenant scope must apply to all tenant-owned resources.

Do not trust request-body `tenantId` for authorization.

Use authenticated server context.

Audit and fix:

- Users
- Employees
- Cases
- Case grants
- Case Clients
- Case Opponents
- Documents
- Hearings
- Service of Process
- Client Meetings
- Tasks
- Calendar
- Payments
- Notifications
- Tenant audit queries
- Object storage paths

Fix current Client read-path backend failures.

Remove permanent dependency on Flutter-side filtering once server-side behavior is correct.

## Phase 2 Tests

- [ ] **P2-T01** Firm A `/users` never contains Firm B users.
- [ ] **P2-T02** Firm A cannot read Firm B user by ID.
- [ ] **P2-T03** Firm A cannot read Firm B Case.
- [ ] **P2-T04** Firm A cannot read/download Firm B Document.
- [ ] **P2-T05** Firm A cannot create a user under Firm B by sending another tenant ID.
- [ ] **P2-T06** Firm A cannot update another tenant's user by ID.
- [ ] **P2-T07** Cross-tenant Case assignment is rejected.
- [ ] **P2-T08** Cross-tenant activity assignment is rejected.
- [ ] **P2-T09** Cross-tenant Payment access is rejected.
- [ ] **P2-T10** Cross-tenant notification access is rejected.
- [ ] **P2-T11** Client list works without 500.
- [ ] **P2-T12** Client detail works without 500.
- [ ] **P2-T13** Object-storage path cannot bypass tenant authorization.
- [ ] **P2-T14** Cross-tenant object IDs do not leak resource existence.
- [ ] **P2-T15** Security regression suite covers every tenant-owned resource.

## Exit Gate

Zero known cross-tenant leaks.

---

# Phase 3 — Identity, Account Types, Provisioning and Base Permissions

## Goal

Migrate identity to the authoritative three-account-type model.

## Required Account Types

```text
SUPER_ADMIN
FIRM_ADMIN
EMPLOYEE
```

## Professional Classifications

```text
LAWYER
SECRETARY
ACCOUNTANT
ASSISTANT
OTHER
```

## Tasks

- Remove authentication-role proliferation.
- Keep professional classification separate.
- Implement ACTIVE / INACTIVE account status.
- Implement secure Firm provisioning.
- Implement atomic Firm + initial Firm Admin provisioning.
- Super Admin assigns Firm Admin permissions.
- Firm Admin creates Employees for own Firm.
- Super Admin may create Employee only after explicitly selecting target Firm.
- Prevent normal creation of Super Admin.
- Disable/remove public signup from v2.
- Add permission-change audit records.
- Apply permission changes immediately.
- Never expose `isSuperAdmin` as a normal client-editable field.

## Phase 3 Tests

- [ ] **P3-T01** Only three account types are accepted.
- [ ] **P3-T02** LAWYER cannot be used as an account type.
- [ ] **P3-T03** Public signup cannot create a Firm.
- [ ] **P3-T04** Normal user-management API cannot create SUPER_ADMIN.
- [ ] **P3-T05** Firm Admin belongs to exactly one tenant.
- [ ] **P3-T06** Employee belongs to exactly one tenant.
- [ ] **P3-T07** Employee creation requires job classification.
- [ ] **P3-T08** Firm Admin cannot create Employee in another Firm.
- [ ] **P3-T09** INACTIVE account loses access on next request.
- [ ] **P3-T10** Firm provisioning rollback leaves no orphan Firm.
- [ ] **P3-T11** Firm provisioning rollback leaves no orphan Firm Admin.
- [ ] **P3-T12** Firm Admin cannot self-grant permission removed by Super Admin.
- [ ] **P3-T13** Super Admin cannot accidentally access tenant legal content through provisioning endpoints.
- [ ] **P3-T14** Permission changes generate audit records.

## Exit Gate

BR-001 through BR-008 identity foundations pass.

---

# Phase 4 — Global References and Lawyer Specializations

## Goal

Implement authoritative Case Types and judicial hierarchy.

## Tasks

Create or normalize:

```text
case_types
lawyer_specializations
governorates
courts
court_circuits
```

Expose read APIs such as:

```text
GET /reference/case-types
GET /reference/governorates
GET /reference/governorates/:id/courts
GET /reference/courts/:id/circuits
```

Exact route naming may differ, but semantics must match.

Firm users cannot create arbitrary Courts/Circuits in v2.

Lawyers require one or more Case Type specializations before legal assignment.

Backend must reject mismatching legal assignments even if the UI is bypassed.

## Phase 4 Tests

- [ ] **P4-T01** Firm A and Firm B see the same global Governorate catalog.
- [ ] **P4-T02** Firm user cannot create a tenant-specific Court.
- [ ] **P4-T03** Alexandria returns only Alexandria Courts.
- [ ] **P4-T04** Court selector returns only Circuits belonging to selected Court.
- [ ] **P4-T05** Invalid Governorate/Court combination is rejected server-side.
- [ ] **P4-T06** LAWYER without specialization cannot be legally assigned.
- [ ] **P4-T07** Criminal Case picker contains only matching Lawyers.
- [ ] **P4-T08** Direct mismatching Lawyer assignment API call fails.
- [ ] **P4-T09** Inactive Case Type remains valid for historical data but unavailable for new assignment.
- [ ] **P4-T10** Reference data returns EN + AR labels.

## Exit Gate

BR-006, BR-013, BR-014, BR-017 and BR-018 pass.

---

# Phase 5 — Case-Centric Data Model Migration

> **Flutter/backend checkpoint (2026-08-15):** [~] Flutter creates Case-owned
> Client and zero-or-more Opponent snapshots, renders capability-gated party
> details, supports the verified Case core/judicial fields, and uses the
> dedicated status endpoint. Case Governorates remain backend references;
> Flutter obtains Courts from Google Places and persists only `courtName`.
> The backend migration copies existing linked Court names before removing the
> Case `default_court_id` relation. Production completion remains blocked by
> BV2-016 (authoritative primary-Lawyer picker data), BV2-021 (no party-snapshot
> update contract), and BV2-022 (lifecycle enum/transition mismatch). BV2-019
> remains relevant to Hearings, but no longer blocks Case Court selection.

## Goal

Make Case the true legal-work aggregate.

## Target Aggregate

```text
Case
├── ClientSnapshot
├── OpponentSnapshots[]
├── CaseAccessGrants[]
├── Documents[]
├── Hearings[]
├── ServiceOfProcess[]
├── ClientMeetings[]
├── Tasks[]
├── Payments[]
└── TimelineEvents[]
```

## Tasks

Replace active v2 reusable Client/Opponent workflows with Case-owned snapshots.

Implement required Case fields:

- internal reference;
- court case number/year;
- title;
- Case Type;
- Governorate;
- Court display name selected from Google Places;
- status;
- opening date;
- description/notes;
- owner Firm Admin;
- agreed fee.

Case lifecycle:

```text
DRAFT
ACTIVE
CLOSED
ARCHIVED
```

Normal user actions must archive rather than physically delete Cases.

## Migration Rule

Historical reusable Client/Opponent data may be retained for migration/history, but new v2 workflow must copy data into independent Case snapshots.

Example:

```text
Old Shared Client
  ├── copy → Case A Client Snapshot
  └── copy → Case B Client Snapshot
```

Case A and Case B must no longer share the same mutable client identity.

## Phase 5 Tests

- [ ] **P5-T01** Every Case has exactly one Client snapshot.
- [ ] **P5-T02** Opponent is optional.
- [ ] **P5-T03** Multiple Opponents work if enabled.
- [ ] **P5-T04** Same real person in Case A and Case B gets separate snapshot records.
- [ ] **P5-T05** Updating Case A client does not alter Case B.
- [ ] **P5-T06** Active Case requires Case Type.
- [x] **P5-T07** A Case persists the Google-selected Court name without a
  backend Court relation; Governorate remains a validated backend reference.
- [ ] **P5-T08** Case archive preserves activity history.
- [ ] **P5-T09** Normal user cannot physically delete Case.
- [ ] **P5-T10** Server sets correct tenant ownership.
- [ ] **P5-T11** Migration preserves old Client/Opponent content.
- [ ] **P5-T12** Archived Cases are excluded from default active list but remain retrievable to authorized users.

## Exit Gate

BR-012 through BR-016 pass.

---

# Phase 6 — Granular Case Permission and Assignment Engine

> **Flutter checkpoint (2026-08-15):** [~] The Case access editor mirrors all
> 36 backend `CaseCapability` values, filters choices by the delegator's base
> permissions, restricts the target picker to active Employees when that
> classification is available, replaces capability sets through PUT, and
> supports explicit full revocation through DELETE. Saving clearly warns that
> it replaces the complete set. Case Details also avoids fetching or rendering
> Hearing, Document, and Finance subresources without their corresponding base
> permissions. Existing grants cannot be displayed or safely prefilled until
> BV2-018 adds a tenant-scoped Case grant-list endpoint.

## Goal

Replace broad CaseTeam-style access with explicit effective capabilities.

## Effective Employee Access

```text
ACTIVE account
AND same tenant
AND required base permission
AND required Case capability
AND professional constraint where applicable
```

Activity assignment may provide only the minimum context required for that activity.

## Example Case Grant

```json
{
  "caseId": "uuid",
  "userId": "uuid",
  "capabilities": [
    "case.view",
    "document.view",
    "document.upload"
  ]
}
```

## Tasks

- Case access grant persistence.
- Capability grant/revoke APIs.
- Effective authorization service.
- Immediate revocation.
- Minimum-context policy for activity-only assignment.
- Assignment audit.
- Same backend policy for web and mobile.
- No hidden broad access implied by job classification.

## Phase 6 Tests

- [ ] **P6-T01** `case.view` allows Case basics.
- [ ] **P6-T02** `case.view` does not imply `document.view`.
- [ ] **P6-T03** `document.upload` does not imply Finance.
- [ ] **P6-T04** Case A grant does not expose Case B.
- [ ] **P6-T05** Revoke Case grant → next request loses access.
- [ ] **P6-T06** Revoke base permission → Case action fails immediately.
- [ ] **P6-T07** Direct API bypass still fails.
- [ ] **P6-T08** Hearing-only assignment shows minimum context.
- [ ] **P6-T09** Hearing-only assignment does not expose unrelated Documents.
- [ ] **P6-T10** Hearing-only assignment does not expose Finance.
- [ ] **P6-T11** Grant/revoke is audit logged.
- [ ] **P6-T12** Firm Admin without granted module permission cannot perform that module action.
- [ ] **P6-T13** Mobile and web receive identical authorization decisions.

## Exit Gate

BR-008 through BR-011 pass.

---

# Phase 7 — Complete Case Activities

> **Flutter checkpoint (2026-08-17):** [~] Phase 7 Flutter activity workflows
> are aligned with the current backend contracts. Hearing creation loads Courts from the Case's
> Governorate, loads Circuits from the selected Court, and keeps every create
> request Case-bound. Hearing completion uses the dedicated
> `PATCH /hearings/:id/complete` contract and validates the required
> 50-character outcome before submission. The normal edit form no longer
> attempts to complete a Hearing through the generic PATCH route. Lawyer
> assignment remains deferred until BV2-016 provides an authoritative active
> Lawyer picker. Service of Process now has a Case-scoped list plus create/edit
> flows, Governorate-scoped Court choices, global Service Method lookups, and
> permission-gated Case Details integration. Flutter document upload now uses
> `POST /documents` with required Case and global Document Category data plus
> optional activity-link metadata. Service completion is enabled for authorized
> users: Flutter uploads PDF/JPEG/PNG evidence linked to the Service, then calls
> the dedicated completion endpoint with `COMPLETED|FAILED`, required result
> notes, and the returned Document ID. Service cancellation now uses the
> backend's retained `CANCELLED` workflow. Client Meetings now have
> permission-gated Case Details list/create/edit flows plus required-outcome
> completion and retained cancellation. Tasks now use the finalized
> `NEW|IN_PROGRESS|WAITING|COMPLETED|CANCELLED` vocabulary, have a Case-scoped
> list/create/edit workflow, use `PATCH /tasks/:id/complete` with a required
> completion note, and cancel through the server's retained `CANCELLED`
> workflow. Normal Flutter activity workflows expose no physical-delete action.
> Phase 7 remains partial: authoritative assignment/reassignment is deferred
> until BV2-016 provides active Employee/Lawyer picker data, and rescheduling
> history plus assignment-isolation exit tests remain backend-owned blockers.

## Goal

Make all v2 scheduled and operational activities first-class Case resources.

---

## 7.1 Hearings

Support:

- Case;
- scheduled date/time;
- Court;
- optional Circuit;
- Hearing Type;
- judge;
- optional legal assignee;
- status;
- outcome;
- next Hearing.

Statuses:

```text
SCHEDULED
COMPLETED
ADJOURNED
CANCELLED
```

No normal hard delete.

---

## 7.2 Service of Process

Complete the existing incomplete backend implementation.

Required fields:

- Case;
- Court;
- schedule;
- assignee;
- recipient/service details;
- notes;
- attachments;
- result;
- completion timestamp.

Statuses:

```text
SCHEDULED
COMPLETED
FAILED
RESCHEDULED
CANCELLED
```

---

## 7.3 Client Meetings

Implement missing module.

Required:

- Case;
- schedule;
- location/method;
- subject;
- assignee;
- status;
- notes/outcome.

Statuses:

```text
SCHEDULED
COMPLETED
CANCELLED
RESCHEDULED
```

---

## 7.4 Tasks

Align Task model and API with finalized PRD vocabulary.

Target status model:

```text
NEW
IN_PROGRESS
WAITING
COMPLETED
CANCELLED
```

If preserving another internal enum for migration reasons, create an explicit mapping and document it.

## Phase 7 Tests

- [x] **P7-T01** Hearing always belongs to a Case.
- [x] **P7-T02** Service of Process always belongs to a Case.
- [x] **P7-T03** Client Meeting always belongs to a Case.
- [ ] **P7-T04** Assigned legal Hearing Lawyer matches Case Type specialization.
- [x] **P7-T05** Hearing completion requires outcome/notes.
- [x] **P7-T06** Service COMPLETED/FAILED requires result or reason.
- [ ] **P7-T07** Rescheduling preserves historical audit evidence.
- [ ] **P7-T08** Meeting assignment changes employee visibility correctly.
- [ ] **P7-T09** Task assignee cannot discover unrelated Cases.
- [ ] **P7-T10** Reassignment immediately updates access.
- [ ] **P7-T11** Activity-only assignment provides minimum context only.
- [x] **P7-T12** Legal-history activities are not physically deleted by normal workflow.

## Exit Gate

Flutter coverage for BR-019 through BR-023 is implemented. The Phase exit gate
remains open pending P7-T04 and P7-T07 through P7-T11 backend-owned assignment,
history, and isolation verification.

---

# Phase 8 — Documents, Versioning, Timeline and Audit

> **Flutter checkpoint (2026-08-17):** [~] Current-version document lifecycle
> is integrated. Case Details supports Case-bound upload, immutable new-version
> upload with an optional change summary, separately permissioned current-file
> download, and retained archive followed by an active-list refresh. Document
> rows show the current version number. Embedded Case timeline events are parsed,
> sorted, and displayed. Flutter exposes no document hard-delete operation.
> Phase 8 remains partial because the backend has no prior-version list/download
> API, no audit-log read API, and incomplete source-verified timeline production
> for all material events.

## Goal

Complete legal-document preservation and case-history requirements.

## Documents

Every legal Document must belong to exactly one Case.

Support:

- category;
- filename;
- MIME type;
- size;
- uploader;
- description;
- optional Hearing link;
- optional Service-of-Process link;
- version;
- archive status;
- download authorization.

Add real version history.

Suggested surface:

```text
GET  /cases/:caseId/documents
POST /cases/:caseId/documents
PATCH /documents/:id
POST /documents/:id/versions
GET  /documents/:id/versions
GET  /documents/:id/download
```

## Case Timeline

Append material events including:

- Case creation;
- status changes;
- grants/revocations;
- assignments;
- activity status changes;
- document uploads/version replacement;
- payments;
- important Client/Opponent edits.

## Audit

Store immutable records with:

```text
actor
tenant
action
entityType
entityId
timestamp
beforeState
afterState
```

## Phase 8 Tests

- [x] **P8-T01** Every uploaded legal Document belongs to a Case.
- [x] **P8-T02** `document.view` alone does not imply download if download is separately permissioned.
- [x] **P8-T03** File replacement creates new version.
- [ ] **P8-T04** Previous version remains available to authorized user.
- [x] **P8-T05** Archive removes Document from normal active list.
- [x] **P8-T06** Normal user cannot hard-delete legal Document.
- [ ] **P8-T07** Firm A cannot download Firm B Document.
- [ ] **P8-T08** Case status change creates Timeline event.
- [ ] **P8-T09** Permission change creates Audit event.
- [ ] **P8-T10** Employee cannot edit/delete Audit records.
- [ ] **P8-T11** Storage paths enforce tenant + Case boundaries.
- [x] **P8-T12** Download authorization is rechecked.

## Exit Gate

Flutter coverage for the supported BR-016/BR-020/BR-026/BR-033 document and
timeline surfaces is implemented. The Phase exit gate remains open pending
prior-version retrieval, complete timeline production, audit visibility, and
backend isolation/immutability verification.

---

# Phase 9 — Unified Calendar and Notifications

> **Flutter checkpoint (2026-08-17):** [~] The unified Calendar now parses the
> current `type`/`startsAt` contract across Custom events, Hearings, Service of
> Process, Client Meetings, and Task due dates. Month range queries include the
> complete final day, and month/week/day views apply source-permission filtering
> before rendering as defense in depth. Notifications retain server-owned unread
> and owned mark-read behavior and now include the authorization-scoped daily
> Hearing/Service/Meeting/Task feed. Phase 9 remains partial because Firm Admin
> source-permission filtering is not enforced server-side, activity deep-link
> flows are not complete, reassignment/schedule-change notifications are
> incomplete, and cross-surface/conflict/deduplication exit tests are backend-owned.

## Goal

Create one authorization-safe operational schedule.

## Calendar Sources

```text
Hearing
Service of Process
Client Meeting
Task Due Date
```

Views:

- month;
- week;
- day.

Firm Admin sees only events permitted by their account permissions.

Employee sees only assigned/authorized activities.

Event detail access must recheck authorization.

## Notifications

Support:

- new assignment;
- reassignment;
- important schedule change;
- access grant/revoke where user action is affected;
- today's assigned Hearing;
- today's Service of Process;
- today's Client Meeting;
- due Tasks;
- read/unread.

Notification bodies must use safe information only.

## Phase 9 Tests

- [ ] **P9-T01** Unauthorized activity does not appear in Employee Calendar.
- [ ] **P9-T02** Revoking Case access removes future Calendar visibility.
- [ ] **P9-T03** Activity-only assignment exposes only that activity.
- [ ] **P9-T04** Unauthorized event deep-link fails server-side.
- [ ] **P9-T05** Assignment creates notification.
- [ ] **P9-T06** Reassignment notifies affected users.
- [ ] **P9-T07** Material schedule change creates notification.
- [ ] **P9-T08** Notification payload does not leak Finance/Opponent/Document data.
- [x] **P9-T09** User cannot mark another user's notification read.
- [ ] **P9-T10** Daily notification job avoids duplicates.
- [ ] **P9-T11** Employee scheduling conflict warning appears for overlapping activities.
- [ ] **P9-T12** Mobile and web Calendar scope match.

## Exit Gate

Flutter coverage for the current Calendar and notification read surfaces is
implemented. The Phase exit gate remains open pending the authorization,
generation, deep-link, conflict, deduplication, and mobile/web parity blockers
recorded in the skipped-phase register.

---

# Phase 10 — Replace Finance with Case Fee + Payment Ledger

> **2026-08-17 checkpoint:** Skipped at the user's direction. No Phase 10
> implementation work was performed in this pass.

## Goal

Implement PRD v2 Finance rather than shipping legacy invoices.

## Case Finance

Case stores:

```text
agreedFee
```

Payment stores:

```text
id
caseId
amount
paidAt
method
referenceNo
notes
recordedBy
isReversed
```

## Calculations

```text
paid = SUM(valid non-reversed payments)
remaining = MAX(agreedFee - paid, 0)
```

## Firm Aggregates

```text
Total Case Value
Total Collected
Total Outstanding
Paid Case Count
Partial Case Count
Unpaid Case Count
```

## Remove from v2 User Flows

- invoice creation;
- invoice lifecycle;
- invoice line items;
- expenses;
- tax accounting;
- payroll;
- general ledger.

Prefer reversal/correction rather than destructive financial deletion.

## Phase 10 Tests

- [ ] **P10-T01** Fee 10000 + payment 3000 → paid 3000 / remaining 7000.
- [ ] **P10-T02** Add payment 2000 → paid 5000 / remaining 5000.
- [ ] **P10-T03** Zero payment rejected.
- [ ] **P10-T04** Negative payment rejected.
- [ ] **P10-T05** Unsupported overpayment rejected.
- [ ] **P10-T06** ACCOUNTANT classification alone grants no finance access.
- [ ] **P10-T07** Case finance grant exposes only authorized Case.
- [ ] **P10-T08** `finance.firm.read` exposes authorized firm totals.
- [ ] **P10-T09** Firm aggregate equals source transactions.
- [ ] **P10-T10** Reversed payment is excluded from totals.
- [ ] **P10-T11** Normal user cannot physically delete financial history.
- [ ] **P10-T12** Firm A cannot read Firm B finance.
- [ ] **P10-T13** Invoice and expense UI is absent from v2.

## Exit Gate

BR-027 through BR-029 pass.

---

# Phase 11 — Super Admin, Plans, Subscriptions and Firm Administration

> **2026-08-17 checkpoint:** The backend-supported Flutter slice is
> implemented: Firm metadata listing/provisioning, platform overview parsing,
> Firm Admin permission replacement, employee metadata/status controls,
> explicit Firm ACTIVE/INACTIVE controls, active-plan listing, and subscription
> activation/cancellation/versioned plan-cycle changes. The permission catalog
> now follows its `{codes: [...]}` response contract, and Firm state remains a
> separate control from subscription state. Automatic expiration, plan CRUD,
> platform-audit reads, and end-to-end enforcement/audit guarantees remain
> backend-blocked in `SKIPPED_PHASE_BACKEND_BLOCKERS.md`.

## Goal

Align SaaS administration with operator-controlled v2 behavior.

## Subscription States

```text
PENDING
ACTIVE
EXPIRED
CANCELLED
```

## Firm States

```text
ACTIVE
INACTIVE
```

Subscription state and Firm state are separate.

An EXPIRED subscription must **not automatically turn the workspace into the old global read-only/blocked state**.

Firm deactivation is an explicit Super Admin action.

## Super Admin Can

- list Firm metadata;
- create Firms;
- provision Firm Admin;
- manage Firm Admin permissions;
- view/update employee account metadata/status;
- manage plans;
- manage subscriptions;
- manage explicit Firm activation/status;
- read platform audit.

## Super Admin Must Not Access

- Case content;
- Client/Opponent legal content;
- tenant Documents;
- Hearing substantive content;
- Service/Meeting substantive content;
- Case Finance.

## Phase 11 Tests

- [ ] **P11-T01** Super Admin can set subscription EXPIRED and the subscription
  status/history update accordingly.
- [ ] **P11-T02** Subscription expiration alone does not create automatic read-only state.
- [ ] **P11-T03** Explicit Firm INACTIVE enforces configured access restriction.
- [ ] **P11-T04** Firm state is independent from subscription state.
- [x] **P11-T05** Super Admin can read Firm metadata.
- [ ] **P11-T06** Super Admin cannot retrieve Case content.
- [ ] **P11-T07** Super Admin cannot download Firm legal Documents.
- [x] **P11-T08** Super Admin can change Firm Admin permission set.
- [ ] **P11-T09** Subscription changes are audited.
- [ ] **P11-T10** Employee cannot manage subscription.
- [ ] **P11-T11** Firm Admin cannot self-grant platform permissions.
- [ ] **P11-T12** Plans created by Seeder remain manageable according to operator policy.

## Exit Gate

BR-003, BR-004, BR-030 and BR-031 pass.

---

# Phase 12 — Web and Flutter v2 Integration

## Goal

Integrate clients only against stable v2 backend behavior.

## Tasks

Update Web and Flutter for:

- three account types;
- professional classification;
- specialization;
- new permission catalog;
- case-local Client/Opponent;
- global judicial references;
- granular Case capabilities;
- Service of Process;
- Client Meetings;
- Tasks;
- unified Calendar;
- notifications;
- Documents/versioning;
- Case Timeline;
- v2 Finance;
- updated subscription behavior.

Remove obsolete behavior and compatibility hacks when backend migration is complete.

## Mobile Security

- Secure token storage.
- No plaintext credentials.
- Optional biometric protection for local session.
- Clear protected cache on logout.
- Refresh protected data after permission changes.
- Avoid indefinite offline visibility after revocation.
- No mobile-only privileged endpoint.
- Server remains authorization source of truth.

## Localization

Full:

```text
English
Arabic
LTR
RTL
Light
Dark
System
```

## Phase 12 Tests

- [ ] **P12-T01** Same user receives same authorization result on web/mobile.
- [ ] **P12-T02** Mobile cannot open hidden Case via deep link.
- [ ] **P12-T03** Permission revocation removes action on refresh.
- [ ] **P12-T04** Logout clears protected session/cache.
- [ ] **P12-T05** Arabic enables RTL correctly.
- [ ] **P12-T06** Language switch does not change authorization/data scope.
- [ ] **P12-T07** Backend validation errors are safely presented.
- [ ] **P12-T08** No AI v2 route/navigation.
- [ ] **P12-T09** No marketplace v2 route/navigation.
- [ ] **P12-T10** No public signup v2 route/navigation.
- [ ] **P12-T11** No invoice/expense v2 route/navigation.
- [ ] **P12-T12** Camera upload follows identical document authorization.
- [ ] **P12-T13** Every permission-hidden UI action is independently protected server-side.

## Exit Gate

BR-034 and client parity pass.

---

# Phase 13 — Production Hardening, Security and DevOps

## Goal

Move from functionally complete to production-safe.

## Security

Run:

- dependency scanning;
- SAST;
- secret scanning;
- authorization fuzzing;
- OWASP API testing;
- IDOR testing;
- mass-assignment testing;
- JWT/session testing;
- brute-force testing;
- upload validation testing;
- rate-limit verification;
- penetration testing.

High-risk fields:

```text
tenantId
accountType
isSuperAdmin
permissionIds
roleIds
caseId
userId
documentId
paymentId
```

## Environment Separation

```text
development
test
staging
production
```

## Production Infrastructure

- TLS.
- Secret manager / deployment secrets.
- Managed database.
- Automated backups.
- Object storage backups/replication.
- Tested restore procedure.
- Structured logging.
- Metrics.
- Error tracking.
- Health checks.
- Readiness checks.
- Alerting.
- Database connection pooling.
- Controlled migration pipeline.

## CI/CD

Recommended:

```text
lint
→ unit tests
→ integration tests
→ contract tests
→ seed verification
→ security checks
→ build
→ deploy staging
→ E2E/UAT
→ manual production approval
```

## Migration Deployment Sequence

```text
backup
→ migration pre-check
→ schema migration
→ seeder/reference-data migration
→ seed verification
→ data integrity validation
→ backend deployment
→ client deployment
→ smoke tests
```

## Phase 13 Tests

- [ ] **P13-T01** Repository secret scan contains zero production secrets.
- [ ] **P13-T02** Authorization penetration suite passes.
- [ ] **P13-T03** IDOR suite passes across all tenant-owned resources.
- [ ] **P13-T04** Malicious uploads rejected.
- [ ] **P13-T05** Oversized uploads rejected.
- [ ] **P13-T06** Invalid/expired JWT rejected.
- [ ] **P13-T07** Refresh-token behavior verified.
- [ ] **P13-T08** Login abuse protection verified.
- [ ] **P13-T09** Database backup successfully restored.
- [ ] **P13-T10** Document store successfully restored.
- [ ] **P13-T11** Seeder can bootstrap a fresh production-like database.
- [ ] **P13-T12** `seed:verify` passes after migration.
- [ ] **P13-T13** Typical list/search operations satisfy performance target.
- [ ] **P13-T14** Alerts fire for repeated authentication/server failures.

## Exit Gate

No Critical/High unresolved production security findings and restore procedure is proven.

---

# Phase 14 — Full Staging UAT and Production Release

## Goal

Validate Hoqooq as a complete system rather than isolated modules.

## Staging Data

Prepare realistic non-production data:

- 1 Super Admin;
- 3+ Firms;
- multiple Firm Admin permission sets;
- Lawyer Employees with different specializations;
- Secretary;
- Accountant;
- Assistant;
- Other/restricted Employees;
- 50–100+ Cases;
- Client/Opponent snapshots;
- Documents;
- Hearings;
- Services of Process;
- Client Meetings;
- Tasks;
- Payments;
- Calendar events;
- Notifications;
- Timeline/Audit records.

Use separate fixture/test seeding for synthetic business data. Do **not** mix demo business records into the production reference-data Seeder.

## Critical End-to-End Journey

```text
Seeder
→ Bootstrap Super Admin
→ Super Admin logs in
→ Create Firm
→ Create Firm Admin
→ Assign Firm Admin permissions
→ Attach subscription/activate firm
→ Firm Admin logs in
→ Create Employees
→ Configure classification/specializations
→ Create Case
→ Enter Case-local Client/Opponent
→ Grant selective Case access
→ Create Hearing
→ Create Service of Process
→ Create Client Meeting
→ Create Task
→ Upload Document
→ Record Payment
→ Verify Calendar/Notifications
→ Employee logs in
→ Employee sees only authorized work
→ Revoke permission
→ Access disappears immediately
```

## Phase 14 Tests

- [ ] **P14-T01** All BR-001 through BR-035 tests pass.
- [ ] **P14-T02** All AC-001 through AC-022 scenarios pass.
- [ ] **P14-T03** Cross-tenant suite passes.
- [ ] **P14-T04** Permission revocation suite passes.
- [ ] **P14-T05** Lawyer specialization suite passes.
- [ ] **P14-T06** Governorate/Court/Circuit suite passes.
- [ ] **P14-T07** Case-local Client/Opponent suite passes.
- [ ] **P14-T08** Finance reconciliation suite passes.
- [ ] **P14-T09** Calendar authorization suite passes.
- [ ] **P14-T10** Notification data-leak suite passes.
- [ ] **P14-T11** Arabic/RTL regression suite passes.
- [ ] **P14-T12** Web/mobile parity suite passes.
- [ ] **P14-T13** Backup/restore test passes.
- [ ] **P14-T14** Rollback procedure is documented and rehearsed.
- [ ] **P14-T15** Seeder idempotency suite passes in staging.
- [ ] **P14-T16** Fresh-database bootstrap reaches usable system state without manual SQL.

---

# Production Blockers

Hoqooq must not be declared production-ready while any of these remain unresolved:

- Cross-tenant `/users` exposure.
- Broken Client list/detail backend queries.
- Authentication model inconsistent with three account types.
- Reusable Client/Opponent active v2 workflow.
- Tenant-managed Court data.
- Missing global Governorate → Court → Circuit hierarchy.
- Missing Lawyer specialization enforcement.
- Broad Case access instead of explicit capabilities.
- Missing Client Meetings.
- Incomplete Service of Process.
- Missing required Case activity authorization.
- Missing Document version-history workflow.
- Missing reliable Case Timeline.
- Invoice/expense Finance exposed as v2 Finance.
- Missing Case payment ledger.
- Automatic subscription middleware conflicting with BR-031.
- Super Admin able to retrieve privileged tenant legal content.
- Privilege-escalation paths through `tenantId`, role or Super Admin fields.
- Public signup exposed as supported v2 flow.
- Marketplace exposed as supported v2 flow.
- AI exposed as supported v2 feature.
- Non-idempotent or insecure production Seeder.
- Production Super Admin credentials committed in source.
- Missing cross-tenant automated regression tests.
- Missing backup/restore verification.

---

# Recommended Implementation Order

```text
Phase 0  — Audit & Traceability
   ↓
Phase 1  — Seeder & Global Bootstrap Data
   ↓
Phase 2  — Security & Tenant Isolation
   ↓
Phase 3  — Identity & Base Permissions
   ↓
Phase 4  — Global References & Specializations
   ↓
Phase 5  — Case-Centric Data Model
   ↓
Phase 6  — Case Capability Engine
   ↓
Phase 7  — Activities
   ↓
Phase 8  — Documents, Timeline & Audit
   ↓
Phase 9  — Calendar & Notifications
   ↓
Phase 10 — Case Finance
   ↓
Phase 11 — Super Admin & Subscription Administration
   ↓
Phase 12 — Web + Flutter v2 Integration
   ↓
Phase 13 — Production Hardening & DevOps
   ↓
Phase 14 — Staging UAT & Production Release
```

---

# Definition of Done for Every Phase

A phase is **DONE** only when all of the following are true:

- [ ] Domain/database behavior matches PRD v2.
- [ ] Backend API behavior matches PRD v2.
- [ ] Server-side authorization is implemented.
- [ ] Tenant isolation is verified.
- [ ] API contract/OpenAPI is updated.
- [ ] Seeder/reference changes are updated when required.
- [ ] Unit tests pass.
- [ ] Integration tests pass.
- [ ] Authorization tests pass.
- [ ] Cross-tenant tests pass.
- [ ] Web integration passes where applicable.
- [ ] Flutter integration passes where applicable.
- [ ] EN/AR behavior passes where applicable.
- [ ] Audit logging exists for required critical actions.
- [ ] No P0 blocker remains for the phase.
- [ ] Documentation and migration notes are updated.

---

# Final Production Release Criteria

Production release is approved only when:

```text
0 Critical defects
0 Critical security issues
0 known tenant-isolation failures
0 failed mandatory BR-001..BR-035 rules
0 failed mandatory AC-001..AC-022 scenarios
0 unresolved privilege-escalation paths
0 migration-integrity failures
0 Seeder idempotency failures
0 web/mobile authorization mismatches
0 backup/restore failures
```

The production-ready Hoqooq v2 system must be able to start from an empty database, execute migrations, execute the production Seeder, verify seeded reference data, provision a Firm, create its Firm Admin, create Employees, manage Cases and legal activities under granular permissions, and preserve strict tenant isolation across both web and mobile clients.
